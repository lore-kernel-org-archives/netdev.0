From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Sat, 05 Sep 2009 02:17:26 +0200
Message-ID: <1252109846.27694.1.camel@violet>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:48868 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933904AbZIEAR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 20:17:26 -0400
In-Reply-To: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

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

can you please give me some feedback on this patch.

Regards

Marcel


