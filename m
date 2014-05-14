From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}:
 Multiple transmit and receive queues
Date: Wed, 14 May 2014 15:13:47 +0100
Message-ID: <20140514141347.GR6332@zion.uk.xensource.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
 <526369072.20140514160923@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	<xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <paul.durrant@citrix.com>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:28477 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbaENONt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 10:13:49 -0400
Content-Disposition: inline
In-Reply-To: <526369072.20140514160923@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 04:09:23PM +0200, Sander Eikelenboom wrote:
> 
> Wednesday, May 14, 2014, 3:52:24 PM, you wrote:
> 
> > This patch series implements multiple transmit and receive queues (i.e.
> > multiple shared rings) for the xen virtual network interfaces.
> 
> > The series is split up as follows:
> >  - Patch 1 brings the 'grant_copy_op' array back into struct xenvif, in
> >    preparation for multi-queue support. See the patch itself for more details.
> > - Patches 2 and 4 factor out the queue-specific data for netback and
> >   netfront respectively, and modify the rest of the code to use these
> >   as appropriate.
> > - Patches 3 and 5 introduce new XenStore keys to negotiate and use
> >   multiple shared rings and event channels, and code to connect these
> >   as appropriate.
> > - Patch 6 documents the XenStore keys required for the new feature
> >   in include/xen/interface/io/netif.h
> 
> > All other transmit and receive processing remains unchanged, i.e. there
> > is a kthread per queue and a NAPI context per queue.
> 
> > The performance of these patches has been analysed in detail, with
> > results available at:
> 
> <snip>
> 
> Would it be possible to also put these somewhere in a tree (or branch of the 
> xen-tree), so it is more easy to pull and test ?
> 

I cannot speak for Andrew. FWIW you can save this thread and use 'git
am' to apply them to 'net-next'.

Wei.

> --
> Sander
> 
> > --
> > Andrew J. Bennieston
> 
> 
