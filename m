From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 08:52:13 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com>
References: <20080616140454.GD5350@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, mirrors@debian.org
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1743 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348AbYFPPwi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 11:52:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080616140454.GD5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:

> Josip Rodin wrote:
> > Hi,
> > 
> > Has anyone seen the below bug before? I'm already upgrading 
> in hope that it
> > might be already fixed in a newer kernel, but anyway.
> > 
> > It started happening a few days ago, on a load of a few 
> tens of MB/s (Debian
> > rsync mirroring). It doesn't happen on every mirror pulse, 
> so it's not
> > exactly reproducible...
> 
> That might be a result of the bug fixed by this commit, which would be
> triggered by heavy traffic:
> 
> commit 6f535763165331bb91277d7519b507fed22034e5
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Thu Oct 11 18:08:29 2007 -0700
> 
>     [NET]: Fix NAPI completion handling in some drivers.
> 

This commit fixed a bug that existed for a very short time after
the patch to make the NAPI struct independent of the netdevice was
committed.

So I think it is unlikely that Josip's panic is caused by this.

Josip, please provide more information such as driver version from
ethtool -i, lspci, which version did you first see the problem, and
whether the latest in 2.6.25 has the same problem.  Thanks.

