From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: use pci_dev->revision, again
Date: Mon, 28 Feb 2011 11:32:34 -0800 (PST)
Message-ID: <20110228.113234.189690963.davem@davemloft.net>
References: <201102282136.44374.sshtylyov@ru.mvista.com>
	<20110228191728.GE2515@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, chris.snook-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jie.yang-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org,
	romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org, sorbica-XpRToVZ20tCCuPEqFHbRBg@public.gmane.org,
	cooldavid-eHdHF5TYP0iWVfeAwA7xHQ@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110228191728.GE2515-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 28 Feb 2011 14:17:29 -0500

> On Mon, Feb 28, 2011 at 09:36:43PM +0300, Sergei Shtylyov wrote:
>> Several more network drivers that read the device's revision ID
>> from the PCI configuration register were merged after the commit
>> 44c10138fd4bbc4b6d6bff0873c24902f2a9da65 (PCI: Change all drivers
>> to use pci_device->revision), so it's time to do another pass of
>> conversion to using the 'revision' field of 'struct pci_dev'...
>> 
>> Signed-off-by: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
>> 
>> ---
>> The patch is against the recent Linus' tree.
>> 
>>  drivers/net/atl1e/atl1e_main.c          |    2 +-
>>  drivers/net/atlx/atl2.c                 |    2 +-
>>  drivers/net/cnic.c                      |   14 +++++---------
>>  drivers/net/e1000e/ethtool.c            |    6 ++----
>>  drivers/net/igbvf/ethtool.c             |    6 ++----
>>  drivers/net/igbvf/netdev.c              |    3 +--
>>  drivers/net/ipg.c                       |    4 +---
>>  drivers/net/ixgbevf/ixgbevf_main.c      |    2 +-
>>  drivers/net/jme.c                       |    2 +-
>>  drivers/net/vxge/vxge-main.c            |   18 +-----------------
>>  drivers/net/wireless/iwlwifi/iwl-3945.c |    4 +---
>>  drivers/net/wireless/iwlwifi/iwl-agn.c  |    2 +-
>>  drivers/net/wireless/rtlwifi/pci.c      |    4 +---
>>  13 files changed, 19 insertions(+), 50 deletions(-)
> 
> ACK

Ok, I'll take these into net-next-2.6 when I get a chance.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
