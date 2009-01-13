From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: possible problem with tg3.c not loading firmware
Date: Tue, 13 Jan 2009 15:13:08 +0100
Message-ID: <496CA174.1030006@hartkopp.net>
References: <496C9F4D.7080101@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux netdev Mailing list <netdev@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:13056 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbZAMONM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 09:13:12 -0500
In-Reply-To: <496C9F4D.7080101@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Joseph Barrow wrote:
> Hi,
> I'm running ubuntu hardy heron 8.0.4.
> my  Ethernet controller is a Broadcom Corporation NetXtreme BCM5788 Gigabit Ethernet (rev 03)
>
> On linux-2.6.28-rc6 for the Tigon 3 driver there doesnt appear to be a seperate firmware file.
> on linux-2.6.29-rc1 there is a tg3_tso5.bin.ihex.
> There appears to be teething problems in getting the firmware file loaded on 2.6.29-rc1.
>
> From the dmesg attached the firmware doesn't appear to be loaded on first boot.
> When I explicitly rmmod & modprobe the tg3 module it then works. 
>
>   

Hi Denis,

it's a know regression, see:

http://marc.info/?l=linux-kernel&m=123182747323724&w=2

Please use CONFIG_FIRMWARE_IN_KERNEL for now to be able to work again.

Regards,
Oliver
