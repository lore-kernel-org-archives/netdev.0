From: Olaf van der Spek <ml@vdspek.org>
Subject: SOMAXCONN = 128, but max defaults to 2048
Date: Sat, 8 Oct 2011 13:51:58 +0200
Message-ID: <CAGVGHmt1OVOj0NSEo3qHCh1CR10eZTNjxuUh_mB6sXxcx5gKmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47151 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab1JHLv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 07:51:59 -0400
Received: by vws1 with SMTP id 1so3715341vws.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 04:51:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

SOMAXCONN is defined as 128, but the max
("/proc/sys/net/ipv4/tcp_max_syn_backlog") appears to be 2048 by
default.
Is the name of SOMAXCONN wrong and is it actually defining the default?
Would there be a disadvantage to defining SOMAXCONN as INT_MAX and
letting the kernel control the actual max?

Greetings,

Olaf
