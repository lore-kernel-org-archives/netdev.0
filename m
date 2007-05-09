From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 09 May 2007 10:22:24 -0400
Message-ID: <4641D920.2020508@roinet.com>
References: <464034CF.20700@wpkg.org> <f1s2eu$26p$1@sea.gmane.org> <20070509092132.GB6976@xi.wantstofly.org> <200705091135.06405.marcus@better.se> <20070509110415.GA7513@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcus Better <marcus@better.se>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:54017
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbXEIOWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 10:22:22 -0400
In-Reply-To: <20070509110415.GA7513@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> The people who need a LE network driver can use Christian's driver,
> as Christian's driver works in LE just fine.  The people who care
> about LE support can add LE support to the driver that Krzysztof wrote.
> 
> I don't think that not supporting LE is a reason not to merge
> Krzysztof's driver.  Don't make supporting LE systems Krzysztof's
> problem.
> 
> Krzysztof has written an excellent driver, and while it would be 100%
> Debian style to reject his driver just because it doesn't support LE[*],
> thankfully, Linux is not Debian.  Please don't turn Linux into Debian.

I am using the ixp425 on the avila from gateworks.  It only has 16 MB of 
  flash built in.  We needed to squeeze a production and a failsafe 
linux inside that so debian was not an option.  I found intel's original 
drivers horrible to read, maintain, and use.  We are using Cristian's 
driver (rev 0.2.1) and are preparing to go to his latest for the crypto 
support.  I only had one bug in 0.2.1, which is fixed in later versions. 
  I would love to see mail line support for this device, including the 
ethernet ports and the crypto capabilities.

We run in big endian despite the extra difficulty in toolset setup and 
finding lots of brain0-damaged-designed-for-x86 code.  We already can 
use up the CPU when we have the mini-pci slots populated with 802.11g 
radios and the ethernet port in use.  Swapping packets would kill us. 
Never mind if we do any kind of software based crypto!  For those of us 
in the embedded space, performance matters.

Big endian is the natural setup for the NPEs on this hardware according 
to the intel documentation.  Please don't stop this driver from moving 
forward so that a few folks can run their hardware in slow mode.

-Ack
