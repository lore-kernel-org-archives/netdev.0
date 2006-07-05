From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RFC] change netdevice to use struct device instead of struct
	class_device
Date: Wed, 05 Jul 2006 16:29:23 +0200
Message-ID: <1152109763.4260.19.camel@localhost>
References: <20060703224719.GA14176@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:20893 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S964886AbWGEO3U
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 10:29:20 -0400
To: Greg KH <greg@kroah.com>
In-Reply-To: <20060703224719.GA14176@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

> The patch needs some other changes to the driver core that are also in
> my git tree, and included in the -mm release.  Specifically these
> patches are needed:
> 	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/device-groups.patch
> 	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/device-class-parent.patch

while converting the Bluetooth subsystem from class devices to real
devices, I had some similar situation with devices without parent. I
actually used a Bluetooth platform device as parent for virtual or
serial based devices.

Regards

Marcel


