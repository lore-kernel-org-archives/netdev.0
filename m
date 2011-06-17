From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 0/2] Allow NICs to pass Frame Checksum up the stack.
Date: Fri, 17 Jun 2011 22:00:28 +0200
Message-ID: <BANLkTikiNT1F39XaMFWc67OuP=StmntL=g@mail.gmail.com>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53877 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932963Ab1FQUAu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:00:50 -0400
Received: by qwk3 with SMTP id 3so97448qwk.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 13:00:49 -0700 (PDT)
In-Reply-To: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/17  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This series provides ethtool support to set and get the rx-checksum
> flag, and adds support to the e100 driver.
[...]

If you want to test the new features approach, you can shave top bit
off NETIF_F_GSO_MASK (there are two unused bits there). The
introducing patch will be +2 lines (+1 dev.c, +1 ethtool.c),
implementation in e100: 20 lines less than patch you sent, ethtool
userspace changes: none (assuming
http://patchwork.ozlabs.org/patch/96374/ or equivalent applied).

Best Regards,
Micha=B3 Miros=B3aw
