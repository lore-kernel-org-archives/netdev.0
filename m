From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 08:41:40 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jeff@lime.pobox.com, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"John Ronciak" <john.ronciak@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:56074 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751334AbWHXPmG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 11:42:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
To: "Jeff Kirsher" <tarbal@gmail.com>,
	"Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:

> The old way of setting autonegotiation was using the 
> following command:
> ethtool -s ethx speed 100 duplex full auto on
> now the command would be
> ethtool -s ethx auto on advertise 0x08
> both commands would result in only advertising 100 FULL.
> 
> There still needs to be a change made to the man file to reflect the
> change in the behavior of ethtool, which I have not done.  But this
> patch will allow for greater flexibility in setting autonegotiation
> speeds.
> 

It is more flexible, but less intuitive.  The user now has to
remember hex values instead of the more intuitive speed and
duplex.  Perhaps we can keep the old method of using speed and
duplex, while adding the new method of specifying hex values? 

