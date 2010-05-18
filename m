From: "Roedel, Joerg" <Joerg.Roedel@amd.com>
Subject: Re: Kernel crash with sky2
Date: Tue, 18 May 2010 13:01:28 +0200
Message-ID: <20100518110128.GK9007@amd.com>
References: <20100517185228.GG9007@amd.com>
 <20100517122236.7f33101f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:50763
	"EHLO VA3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750895Ab0ERLBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:01:40 -0400
Content-Disposition: inline
In-Reply-To: <20100517122236.7f33101f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Mon, May 17, 2010 at 03:22:36PM -0400, Stephen Hemminger wrote:
> On Mon, 17 May 2010 20:52:28 +0200
> Joerg Roedel <joerg.roedel@amd.com> wrote:
> > I experience the following crash with 2.6.34 in the sky2 code on my
> > laptop when I plug off the lan-cable and then plug-off the power cable
> > and switching to battery. It does not happen with acpi=off.
> 
> So you have a busted BIOS that powers off the device.

Yeah you are right, its a BIOS issue. I tried to find out how the OS is
informed about the device taken away. But none of the hotplug
drivers or enabling acpi debug showed anything here. I wonder how this
is done in the "other" operating system. Or how the device could be
re-enabled, plugging the wires back doesn't help. Very weird.
Anyway, I found a BIOS option to disable this behavior and now things
work unpatched. Thanks for your help.

	Joerg


