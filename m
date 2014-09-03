From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast address
 to ALE table
Date: Wed, 3 Sep 2014 13:58:24 +0530
Message-ID: <5406D128.3080304@ti.com>
References: <1409682156.3334.16.camel@fromme.threespeedlogic.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Graeme Smecher <gsmecher@threespeedlogic.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:45733 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755622AbaICI21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 04:28:27 -0400
In-Reply-To: <1409682156.3334.16.camel@fromme.threespeedlogic.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Graeme

There is already a support for add multicast in v2.6.37 cpsw driver, if
there is a bug and you found a fix, can go a head and fix that. The
patch you have mentioned is an upstream patch with was done on top of
am335x platform, so there might be bugs fixed and added into the patch
which are not in v2.6.37 cpsw driver.

Regards
Mugunthan V N

On Tuesday 02 September 2014 11:52 PM, Graeme Smecher wrote:
> Hi Mugunthan,
> 
>> On Wed, Oct 17, 2012 at 04:15:15AM +0530, Mugunthan V N wrote:
>>> Adding multicast address to ALE table via netdev ops to subscribe, transmit
>>> or receive multicast frames to and from the network
>>
>> Is this somehow related to the time stamping function? If so, how?
>>
>> Thanks,
>> Richard
> 
> Can you give me a brief description of this (relatively ancient) patch? Your
> original e-mail is visible here:
> 
> 	http://marc.info/?l=linux-netdev&m=135042754927177&w=2
> 
> I'm wondering if this patch needs to be backported to older CPSW driver
> snapshots (specifically, TI's 2.6.37 branch for dm81xx.) It appears to
> fix a multicast bug I'm tracking down, but it's difficult to know for
> sure without a good description of what problem the patch addresses. (I
> don't want to commit code that fixes my hardware by accident.)
> 
> For a little more information, you can refer to my e2e.ti.com post:
> 
> 	http://e2e.ti.com/support/dsp/davinci_digital_media_processors/f/716/t/365586.aspx
> 
> I'm slowly learning about ALE filtering, but a quick reply from a
> domain expert would be very helpful.
> 
> best,
> Graeme
> 
