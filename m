From: James Chapman <jchapman@katalix.com>
Subject: Re: Network device driver with PPP
Date: Thu, 28 Feb 2008 09:27:03 +0000
Message-ID: <47C67E67.70604@katalix.com>
References: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local> <1204164955.26292.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kevin Lloyd <klloyd@sierrawireless.com>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33780 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754965AbYB1J1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 04:27:09 -0500
In-Reply-To: <1204164955.26292.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:
> On Wed, 2008-02-27 at 17:28 -0800, Kevin Lloyd wrote:
>> Hi all,
>>
>> I have a device that is currently supported via a combination of loading the device with usb-serial (drivers/usb/serial/sierra) to expose the serial ports and connecting by manually launching pppd.
>> I would like to support this device in a network driver as opposed to a serial driver in an effort to offer a seamless always-on device, such as an Ethernet device.
>>
>> From what I understand the ppp support in the kernel is only for ppp framing and that all control (e.g., IPCP) is done in user-space via pppd. Are there any network drivers that currently manage the ppp connection (entirely, IPCP included) internally to the driver and expose either a raw ip or ethernet stream to the user-space?
> 
> That seems quite icky to do all in kernel space and a pile of code
> running in the kernel.  What's so wrong with userspace?  Don't you need
> to push values to the driver like username/password and get IP config
> out of it (which would involve userspace anyway)?  It just seems like
> there's a different solution to your actual problem here than stuff all
> off pppd into kernel space.

I agree.

Kevin mentions manually launching pppd and the desire for a seamless 
always-on device. I think this could be done using udev/hotplug rules to 
launch/stop pppd automatically when the usb device is hot-plugged. No 
additional kernel support needed.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

