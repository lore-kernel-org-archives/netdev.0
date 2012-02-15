From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 01:03:46 -0500
Message-ID: <CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	<5133914.uYLb0gnNTc@localhost.localdomain>
	<1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<5781419.24ZaHfTAxC@localhost.localdomain>
	<1329280993.2555.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: alekcejk@googlemail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:44070 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab2BOGDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 01:03:47 -0500
Received: by qafk1 with SMTP id k1so752078qaf.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 22:03:46 -0800 (PST)
In-Reply-To: <1329280993.2555.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some potentially interesting differences in sysctl values:

> diff -u /tmp/sysctl-a-3.1.txt /tmp/sysctl-a-3.2.txt  | grep mem_def
-net.core.wmem_default = 114688
-net.core.rmem_default = 114688
+net.core.wmem_default = 163840
+net.core.rmem_default = 163840

Can you please try running this as root on the 3.2 kernel and then see
what sort of performance you get:

sysctl net.core.rmem_default=114688

This should make the 3.2 config closer to the 3.1 config. Should be
interesting to see if the behavior is more similar when that happens.

neal
