From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] 6lowpan: mac802154: fix
 coding style issues
Date: Tue, 1 Jul 2014 21:20:28 -0700
Message-ID: <CAGVrzcYc9u2TAxhb8vPOevLYiZUsOyEcUAbxZ4aLrns3Vt97yw@mail.gmail.com>
References: <1404271869-2316-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Varka Bhadram <varkab@cdac.in>,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	Joe Perches <joe@perches.com>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:60175 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaGBEVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:21:09 -0400
Received: by mail-ob0-f169.google.com with SMTP id wp18so11810781obc.0
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:21:08 -0700 (PDT)
In-Reply-To: <1404271869-2316-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-07-01 20:31 GMT-07:00 Varka Bhadram <varkabhadram@gmail.com>:
> This patch fixed the coding style issues reported by checkpatch.pl
>
> following issues fixed:
>         CHECK: Alignment should match open parenthesis

It seems to me like checkpatch.pl should have a special case for
networking code and that specific condition because fixing things to
make checkpatch.pl happy seems not to agree with the general coding
style recommended and enforced in the networking code.

I just saw that new warning added popping up on a bunch of drivers
that were properly fixed to match the networking coding style before
submission.
--
Florian
