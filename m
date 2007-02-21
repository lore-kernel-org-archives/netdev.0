From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [git patches] net driver updates
Date: Wed, 21 Feb 2007 08:27:54 -0500
Message-ID: <20070221132754.GA4978@tuxdriver.com>
References: <6.1.1.1.2.20070221124144.04783fb8@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roger While <simrw-95wjJ3trAfEOIzVOb1FTxg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6.1.1.1.2.20070221124144.04783fb8-Q0ErXNX1RuZq5LbY+mFP1w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 12:46:46PM +0100, Roger While wrote:
> 
> >
> >Dan Williams (1):
> >      prism54: correct assignment of DOT1XENABLE in WE-19 codepaths
> 
> Where did this spring from ?
> I see no posting of this patch let alone
> an ACK.
> The patch is also doing rather more than the description -
> It is inserting extra breaks into a switch statement with
> no comment as to why.

Dan posted it to linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org on 13 Feb 2007.
The description in the body is quoted below:

	Correct assignment of DOT1XENABLE in WE-19 codepaths.
	RX_UNENCRYPTED_EAPOL = 1 really means setting DOT1XENABLE _off_, and
	vice versa.  The original WE-19 patch erroneously reversed that.  This
	patch fixes association with unencrypted and WEP networks when using
	wpa_supplicant.
	
	It also adds two missing break statements that, left out, could result
	in incorrect card configuration.
	
	Please commit to both development and stable branches.

Hth...

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
