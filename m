From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: FW: + qla3xxx-is-bust.patch added to -mm tree
Date: Wed, 28 Jun 2006 16:07:22 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Linux Driver" <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:15607 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1751436AbWF1XHX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 19:07:23 -0400
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Is the device hotpluggable?   If so, this:
> 
> 	qdev->index = cards_found;
> 
> in the probe() handler might do odd things - it'll just keep 
> increasing as the card is removed and re-added.
> 
> iirc, that's a common problem with net drivers.  AFAICT it'll 
> cause only cosmetic oddities here.
> 
>

Not sure if the device supports hotplug.  I'm looking into it.  Either
way, I will be removing qdev->index.  It's not needed. 

I am working on the remaining items that Jeff pointed out when he
reviewed my driver.  I will forward a patch built against what you
currently have when I'm done.

Now that the driver is in mm tree, is there anything I need to do to get
it into Linus' tree?
