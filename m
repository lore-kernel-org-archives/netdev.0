From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: Re: ZD1211RW unaligned accesses...
Date: Sat, 1 Dec 2007 11:33:50 +0100
Message-ID: <20071201103350.GB25387@deine-taler.de>
References: <20071120.040546.222294375.davem@davemloft.net> <47442BFC.8090008@hotmail.com> <20071124150216.GA28153@gondor.apana.org.au> <20071129214533.GD32730@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Shaddy Baddah <shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071129214533.GD32730-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:

> So, did the patch below fix the problem?  Should I apply it?
> 
> John

John,

the patch would have worked, but I have sent a second one to the
list, which is based on Herbert's and has an assert to be able to test
the patch on x86.

You should be notify that the mac80211 driver, doesn't suffer
from the problem and Daniel has already provided a patch to
replace zd1211rw by the mac80211 driver. Daniel's patch must of
course break by the new patch.

-- 
Uli Kunitz
