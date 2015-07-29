From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Wed, 29 Jul 2015 14:50:10 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1507291449180.1712@denkbrett>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett> <5592913C.3000207@mellanox.com> <alpine.LFD.2.11.1506301520180.1799@denkbrett> <55929F2D.9050805@mellanox.com> <alpine.LFD.2.11.1506301615100.1799@denkbrett> <5593E88F.10006@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:40438 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbbG2MuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 08:50:18 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
	Wed, 29 Jul 2015 13:50:16 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6F15217D8024
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 13:51:39 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6TCoDCZ34930910
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 12:50:13 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6TCoCuu026989
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 06:50:13 -0600
In-Reply-To: <5593E88F.10006@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jul 2015, Or Gerlitz wrote:
> On 6/30/2015 5:17 PM, Sebastian Ott wrote:
> > On Tue, 30 Jun 2015, Or Gerlitz wrote:
> > > On 6/30/2015 4:24 PM, Sebastian Ott wrote:
> > > > > > Do you run the VF on the same system/kernel as the PF, or the VF is
> > > > > > probed to
> > > > > > VM which runs the latest kernel and the PF runsolder kernel (which?)
> > > > The latter case. The PF is driven by a much older Kernel running OFED
> > > > 2.3.2.0.0.1
> > > >
> > > Can you try running the inbox PF driver that comes with the PF kernel
> > > (what
> > > kernel is that?) I'd like to see we're OK there.
> > Frankly, I don't know. Plus I also don't know how to build an ofed kernel.
> >
> 
> I didn't want you to build that package, but rather the outer way around,
> namely
> see what happens if uninstalling this package and running with the mlx4 inbox
> PF
> driver from the kernel provided from your distro of choice or an
> upstreamkernel installed
> by you. Anyway, I hope the below patch would provide a quick band-aid and let
> you to continue running upstream VFs over that PF config, let me know (I will
> be
> OOO till Thu-Sun). Once we see how this behaves, will take it from there.

Any updates on this one?

Regards,
Sebastian
