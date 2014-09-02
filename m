From: Graeme Smecher <gsmecher@threespeedlogic.com>
Subject: Re: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast address
 to ALE table
Date: Tue, 02 Sep 2014 11:22:36 -0700
Message-ID: <1409682156.3334.16.camel@fromme.threespeedlogic.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2s63.a2hosting.com ([75.98.166.66]:60253 "EHLO
	a2s63.a2hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbaIBUPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:15:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mugunthan,

> On Wed, Oct 17, 2012 at 04:15:15AM +0530, Mugunthan V N wrote:
> > Adding multicast address to ALE table via netdev ops to subscribe, transmit
> > or receive multicast frames to and from the network
> 
> Is this somehow related to the time stamping function? If so, how?
> 
> Thanks,
> Richard

Can you give me a brief description of this (relatively ancient) patch? Your
original e-mail is visible here:

	http://marc.info/?l=linux-netdev&m=135042754927177&w=2

I'm wondering if this patch needs to be backported to older CPSW driver
snapshots (specifically, TI's 2.6.37 branch for dm81xx.) It appears to
fix a multicast bug I'm tracking down, but it's difficult to know for
sure without a good description of what problem the patch addresses. (I
don't want to commit code that fixes my hardware by accident.)

For a little more information, you can refer to my e2e.ti.com post:

	http://e2e.ti.com/support/dsp/davinci_digital_media_processors/f/716/t/365586.aspx

I'm slowly learning about ALE filtering, but a quick reply from a
domain expert would be very helpful.

best,
Graeme
