From: Jeff Garzik <jeff@garzik.org>
Subject: Re: FW: + qla3xxx-is-bust.patch added to -mm tree
Date: Wed, 28 Jun 2006 21:37:47 -0400
Message-ID: <44A32EEB.3080503@garzik.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Linux Driver <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47582 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751170AbWF2Bhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 21:37:52 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
>> Is the device hotpluggable?   If so, this:
>>
>> 	qdev->index = cards_found;
>>
>> in the probe() handler might do odd things - it'll just keep 
>> increasing as the card is removed and re-added.
>>
>> iirc, that's a common problem with net drivers.  AFAICT it'll 
>> cause only cosmetic oddities here.
>>
>>
> 
> Not sure if the device supports hotplug.  I'm looking into it.  Either

If its a PCI device, it does...  depends more on the bus than the device.


> way, I will be removing qdev->index.  It's not needed. 

Sounds good.


> I am working on the remaining items that Jeff pointed out when he
> reviewed my driver.  I will forward a patch built against what you
> currently have when I'm done.
> 
> Now that the driver is in mm tree, is there anything I need to do to get
> it into Linus' tree?

Fix the stuff I pointed out...

	Jeff


