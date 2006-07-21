From: Theodore Tso <tytso@mit.edu>
Subject: Re: e1000: "fix" it on thinkpad x60 / eeprom checksum read fails
Date: Fri, 21 Jul 2006 11:12:39 -0400
Message-ID: <20060721151239.GC2290@thunk.org>
References: <20060721005832.GA1889@elf.ucw.cz> <44BFADA6.6090909@intel.com> <20060720170758.GA9938@atrey.karlin.mff.cuni.cz> <44BFBE9F.7070600@intel.com> <20060721064105.aa960acd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>, pavel@ucw.cz,
	cramerj@intel.com, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750757AbWGUPMu@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060721064105.aa960acd.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 06:41:05AM -0700, Andrew Morton wrote:
> > It's completely not acceptable to run when the EEPROM checksum fails - you 
> > might even be running with the wrong MAC address, or worse. Lets fix this the 
> > right way instead.
> 
> A printk which helps the user to understand all this saga would be very nice.
> -

And if someone who understands all of these details could put a note
in the thinkwiki (say, here:
http://www.thinkwiki.org/wiki/Ethernet_Controllers#Intel_Gigabit_.2810.2F100.2F1000.29)
it would be greatly appreciated.

						- Ted
