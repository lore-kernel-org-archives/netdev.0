From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network device driver with PPP
Date: Wed, 27 Feb 2008 21:15:55 -0500
Message-ID: <1204164955.26292.5.camel@localhost.localdomain>
References: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Lloyd <klloyd@sierrawireless.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbYB1CSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 21:18:20 -0500
In-Reply-To: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-27 at 17:28 -0800, Kevin Lloyd wrote:
> Hi all,
> 
> I have a device that is currently supported via a combination of loading the device with usb-serial (drivers/usb/serial/sierra) to expose the serial ports and connecting by manually launching pppd.
> I would like to support this device in a network driver as opposed to a serial driver in an effort to offer a seamless always-on device, such as an Ethernet device.
> 
> From what I understand the ppp support in the kernel is only for ppp framing and that all control (e.g., IPCP) is done in user-space via pppd. Are there any network drivers that currently manage the ppp connection (entirely, IPCP included) internally to the driver and expose either a raw ip or ethernet stream to the user-space?

That seems quite icky to do all in kernel space and a pile of code
running in the kernel.  What's so wrong with userspace?  Don't you need
to push values to the driver like username/password and get IP config
out of it (which would involve userspace anyway)?  It just seems like
there's a different solution to your actual problem here than stuff all
off pppd into kernel space.

Dan



