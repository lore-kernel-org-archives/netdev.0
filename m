From: Andrew Morton <akpm@osdl.org>
Subject: Re: e1000: "fix" it on thinkpad x60 / eeprom checksum read fails
Date: Fri, 21 Jul 2006 06:41:05 -0700
Message-ID: <20060721064105.aa960acd.akpm@osdl.org>
References: <20060721005832.GA1889@elf.ucw.cz>
	<44BFADA6.6090909@intel.com>
	<20060720170758.GA9938@atrey.karlin.mff.cuni.cz>
	<44BFBE9F.7070600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, auke-jan.h.kok@intel.com, cramerj@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39659 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750731AbWGUNrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 09:47:52 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44BFBE9F.7070600@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Jul 2006 10:34:23 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> > Okay, perhaps this should be inserted as a comment into the driver,
> > and printk should be fixed to point at this explanation?
> > 
> > Can't we enable the driver with the bad checksum, then read the _real_
> > data?
> 
> no.
> 
> We're working on a solution where we make sure that the PHY is physically 
> turned on properly before we read the EEPROM, which would be the proper fix. 
> It's completely not acceptable to run when the EEPROM checksum fails - you 
> might even be running with the wrong MAC address, or worse. Lets fix this the 
> right way instead.

A printk which helps the user to understand all this saga would be very nice.
