From: Joe Perches <joe@perches.com>
Subject: Re: chelsio: Use a more common const struct pci_device_id foo[]
 style
Date: Mon, 16 Feb 2015 11:18:29 -0800
Message-ID: <1424114309.8287.5.camel@perches.com>
References: <1423879550.2795.12.camel@perches.com>
	 <4985EFDD773FCB459EF7915D2A3621ADB9E00A@nice.asicdesigners.com>
	 ,<1424110879.8287.3.camel@perches.com>
	 <4985EFDD773FCB459EF7915D2A3621ADB9E035@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hariprasad S <hariprasad@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	David Miller <davem@redhat.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4985EFDD773FCB459EF7915D2A3621ADB9E035@nice.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-16 at 19:07 +0000, Casey Leedom wrote:
>   I understand that OS-independence issues aren't something which are
> normally accommodated, but as long as definitions don't introduce
> unnecessary "foreign intrusion" I would hope that it would be okay.
> As I noted, our t4_regs.h file is also OS-independent and used by six
> other OS device drivers.  Putting Linux definitions into
> t4_pci_id_tbl.h would be somewhat akin to injecting Linux dependencies
> into t4_regs.h.
> 
>   But, if the change must be made, then we'll just maintain a
> translation between our Common Code and the kernel.org code.  If
> that's the case, probably the best documentation for the proposed
> CH_PCI_ID_TABLE_ENTRY_DATA might be something like:
> 
>  * CH_PCI_ID_TABLE_ENTRY_DATA
>  *   -- Used for the individual PCI Device ID entries for the
> PCI_VDEVICE() "dev"
>  *   -- parameter.
> 
>   So it sounds like Chelsio would be required to make this change
> then?  I'm still unclear on the likes of responsibility/authority
> here.  We're being told that we must do this but we have to be the
> ones requesting it?  Sorry for my confusion.

It's just a suggested patch.
It's your code, you don't _have_ to do anything.

> (Which is doubly apparent since I came into work this morning only to
> realize that it's a company holiday.  Color me a moron today.)

Yay for holidays.

It can be personally beneficial to take the day off.
It could also be very productive to work with no distractions.

As always, your choice...

cheers, Joe
