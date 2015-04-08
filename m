From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Wed, 08 Apr 2015 11:08:45 +0200
Message-ID: <1749676.NUxJ1eyH1x@msg-id>
References: <2142872.6QHf5ZAfZz@msg-id> <5524ED4F.9070907@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38639 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbDHJIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 05:08:53 -0400
Received: by wiun10 with SMTP id n10so50027967wiu.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 02:08:52 -0700 (PDT)
In-Reply-To: <5524ED4F.9070907@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Hi,
Hi,
thank you for thaking to the time to answer

> Salvatore Mesoraca wrote:
> > From: Vasiliy Kulikov <segooon@gmail.com>
> > 
> > This patch adds non-raw IPPROTO_ICMP socket kind support that was added
> > to the Linux 3.0.  The patch is backward-compatible: if ICMP socket kind
> > is not enabled in the kernel (either in case of an old kernel or
> > explicitly disabled via /proc/sys/net/ipv4/ping_group_range), ping uses
> > old privileged raw sockets as a fallback.
> > 
> > This patch is going to be included in Ubuntu 15.10 and it is already
> > included in Gentoo stable tree (at the moment of the writing ping has
> > CAP_NET_RAW still enabled by default) it is also included in OpenWall
> > since 2011.
> > This patch also tries to sneak in a fix for a missing colon in a printf.
> > I've tested it on Linux 3.17.7 and it worked without issues.
> 
> Please do not mix changes in a single commit.
> Thanks.

I had some doubt about that additional change (it is so small that I don't 
think that anyone will ever make a separate patch for it), but it was present 
in the original patch and I decided to add it anyway and wait for feedback.
I'll delete it.
Thank you again for you comment.
