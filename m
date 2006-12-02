From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: 2.6.19: very low transmit speed after suspend/resume with Sky2
Date: Sat, 2 Dec 2006 23:37:03 +0100
Message-ID: <20061202223703.GA16068@dose.home.local>
References: <20061202091626.GA20734@thinkpad.home.local> <20061202131833.GA3673@thinkpad.home.local> <4571ED2C.6040005@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:54704 "EHLO
	eazy.amigager.de") by vger.kernel.org with ESMTP id S936570AbWLBWhF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 17:37:05 -0500
Received: from dose.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id D833025C3B3
	for <netdev@vger.kernel.org>; Sat,  2 Dec 2006 23:37:02 +0100 (CET)
Received: from scorpion by dose.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1GqdTj-0004LZ-6e
	for netdev@vger.kernel.org; Sat, 02 Dec 2006 23:37:03 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <4571ED2C.6040005@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 02, 2006 at 13:16:28 -0800, Stephen Hemminger wrote:

[...]

> Most likely, the problem is similar to one I am working. The 

Great to hear that someone is working on this. If you need a tester,
just ask. :-)

> device_resume code gets run before
> BIOS. And the BIOS wakeup screws up the device. The proper fix will 
> happen in 2.6.20.
> If you are using MSI, turn that off.

I don't use it:

# CONFIG_PCI_MSI is not set

Regards,
Tino
