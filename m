From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Can we remove pci_find_device() yet?
Date: Thu, 14 Jan 2010 11:18:12 +0100
Message-ID: <877hrlf0rf.fsf@basil.nowhere.org>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
	<20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc>
	<20100111200136.GA29955@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tilman Schmidt <tilman@imap.cc>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755632Ab0ANKSS@vger.kernel.org>
In-Reply-To: <20100111200136.GA29955@suse.de> (Greg KH's message of "Mon, 11 Jan 2010 12:01:36 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@suse.de> writes:
>
> Close, but if you do this, please name the function
> hisax_find_pci_device() or something, and change the drivers to use it
> instead.  Also put a big fat warning in the function that calling this
> is unsafe for any PCI hotplug type machine.

It would be better to enforce this constraint at runtime.

e.g. set some global variable that forbids device removal
and warn in the kernel log. In theory this could be also
done per device, but I guess that would be more effort.

Of course it cannot prevent the user from really removing
a device, but at least the pci_dev could stay around.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
