From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Fri, 11 Sep 2009 12:37:39 -0700 (PDT)
Message-ID: <20090911.123739.202533046.davem@davemloft.net>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756191AbZIKThX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:37:23 -0400
In-Reply-To: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue,  1 Sep 2009 00:08:19 -0700

> The Ethernet framing is used for a lot of devices these days. Most
> prominent are WiFi and WiMAX based devices. However for userspace
> application it is important to classify these devices correctly and
> not only see them as Ethernet devices. The daemons like HAL, DeviceKit
> or even NetworkManager with udev support tries to do the classification
> in userspace with a lot trickery and extra system calls. This is not
> good and actually reaches its limitations. Especially since the kernel
> does know the type of the Ethernet device it is pretty stupid.
> 
> To solve this problem the underlying device type needs to be set and
> then the value will be exported as DEVTYPE via uevents and available
> within udev.
> 
>   # cat /sys/class/net/wlan0/uevent
>   DEVTYPE=wlan
>   INTERFACE=wlan0
>   IFINDEX=5
> 
> This is similar to subsystems like USB and SCSI that distinguish
> between hosts, devices, disks, partitions etc.
> 
> The new SET_NETDEV_DEVTYPE() is a convenience helper to set the actual
> device type. All device types are free form, but for convenience the
> same strings as used with RFKILL are choosen.
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Applied to net-next-2.6, thanks.
