From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support to
 NEW EMAC.
Date: Mon, 15 Oct 2007 13:59:59 -0500
Message-ID: <20071015135959.5b603d7d@weaponx.rchland.ibm.com>
References: <20071015175717.GA4602@ru.mvista.com>
	<4713B10B.5000607@garzik.org>
	<20071015134813.6aacdcca@weaponx.rchland.ibm.com>
	<4713B726.6080404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Valentine Barshak <vbarshak@ru.mvista.com>,
	Michael Ellerman <michael@ellerman.id.au>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43137 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783AbXJOTAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 15:00:10 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9FJ04Ak009109
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 15:00:04 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FJ019n412272
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 13:00:01 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FJ00YG029867
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 13:00:01 -0600
In-Reply-To: <4713B726.6080404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007 14:53:26 -0400
Jeff Garzik <jeff@garzik.org> wrote:
> >> Seems sane to me -- ACK -- but we have multiple people sending me 
> >> patches for a single driver.  That's normal for janitorial cleanups 
> >> across the whole tree, but discouraged when multiple people are actively 
> >> working on the same driver.
> >>
> >> Please coordinate, and have ONE person send me patches...
> > 
> > Who else is sending you patches?  Valentine is the only one I've seen
> > send patches recently...
> 
> It's a zoo :)

Wow, indeed.

> Al Viro (3):
>        typo in ibm_newemac/rgmii.c

Val sent this as well.  Either one works.

>        skb->tail in ibm_newemac should be skb_tail_pointer()
>        ibm_newemac annotations (iomem, NULL noise)

Ack on those.

> David Gibson (1):
>        Device tree aware EMAC driver

That's the initial commit :)

> Michael Ellerman (3):
>        Update ibm_newemac to use dcr_host_t.base
>        Add dcr_host_t.base in dcr_read()/dcr_write()
>        Use dcr_host_t.base in dcr_unmap()

Missed those, but I see you applied them which is good.

> Roland Dreier (2):
>        ibm_new_emac: Nuke SET_MODULE_OWNER() use
>        ibm_emac: Convert to use napi_struct independent of struct net_device

I never saw either of these.  I'm also beginning to wonder if one of
them broke things because I can't currently get ibm_newemac to work.

> vbarshak@ru.mvista.com (1):
>        Fix typo in new EMAC driver.

Same fix as Al's.

Anyway, we can queue patches to this through me if you'd like.

josh
