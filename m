From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Thu, 15 Oct 2009 07:20:41 +1030
Message-ID: <20091015072041.6ebae736@opy.nosense.org>
References: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
	<20091014.131526.181354809.davem@davemloft.net>
	<A2EB721D-3AC9-4815-ADCC-EC0B311C5AE7@ntop.org>
	<20091014.132911.174712308.davem@davemloft.net>
	<C803B824-8249-44BA-ACCD-D9AE4AA21F92@ntop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bcook@bpointsys.com,
	brad.doctor@gmail.com, netdev@vger.kernel.org
To: Luca Deri <deri@ntop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:37558 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756549AbZJNUve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 16:51:34 -0400
In-Reply-To: <C803B824-8249-44BA-ACCD-D9AE4AA21F92@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luca, David,

On Wed, 14 Oct 2009 22:34:17 +0200
Luca Deri <deri@ntop.org> wrote:

> David
> so do you want me to start porting PF_RING facilities into PF_PACKET?  
> As I have said I;m not against this: my goal is to include this work  
> into the linux kernel, as it has been separate for too long.
> 

I'd like to see that. One of my main uses for Linux is as a network
troubleshooting "pocket knife", so anything that can improve or make
more functional the packet capturing capabilities is really appreciated
by people like me.

Thanks,
Mark.

> Luca
> 
> On Oct 14, 2009, at 10:29 PM, David Miller wrote:
> 
> > From: Luca Deri <deri@ntop.org>
> > Date: Wed, 14 Oct 2009 22:26:25 +0200
> >
> >> I agree that some PF_RING features could be merged into
> >> PF_PACKET. However PF_RING is not just about improving packet capture
> >> but it implements facilities that can be used by many monitoring
> >> applications including, packet balancing, reflection, layer-7 packet
> >> filtering, pf_ring socket clustering just to name a few. You can read
> >> about PF_RING feature into this tutorial:
> >> http://luca.ntop.org/IM2009_Tutorial.pdf
> >
> > I've already researched several times what PF_RING does and
> > is capable of doing, and my position still stands that none of
> > it can't be added to existing facilities.
> >
> > It's been an out of tree hack for years, and if it stays as
> > a seperate facility it's likely to stay that way.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
