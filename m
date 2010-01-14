From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Can we remove pci_find_device() yet?
Date: Thu, 14 Jan 2010 12:03:54 +0100
Message-ID: <20100114110354.GJ12241@basil.fritz.box>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de> <877hrlf0rf.fsf@basil.nowhere.org> <20100114110214.37d7ffc9@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Greg KH <gregkh@suse.de>,
	Tilman Schmidt <tilman@imap.cc>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756157Ab0ANLD5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100114110214.37d7ffc9@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2010 at 11:02:14AM +0000, Alan Cox wrote:
> > e.g. set some global variable that forbids device removal
> > and warn in the kernel log. In theory this could be also
> > done per device, but I guess that would be more effort.
> 
> There is a simpler way to do that, which is to just leak a reference in
> the hisax_find_pci_device hack. The pci_dev won't be going anywhere then.

You just have to do it once, otherwise it'll fail after 4 billion times.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
