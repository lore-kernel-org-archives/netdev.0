From: Gustavo Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH 1/2] bluetooth: Use more current logging styles
Date: Mon, 13 Feb 2012 19:56:03 -0200
Message-ID: <20120213215603.GA27753@joana>
References: <cover.1329102581.git.joe@perches.com>
 <44b8744770a55924c68f8ad0ca274816d2d6148f.1329102581.git.joe@perches.com>
 <1329114913.28848.50.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1329114913.28848.50.camel@aeonflux>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe,

* Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> [2012-02-13 07:35:13 +0100]:

> Hi Joe,
> 
> > Make functions for bt_info and bt_err.
> > Remove now unused function bt_printk.
> > Convert uses of BT_INFO and BT_ERR to bt_info and bt_err.
> 
> That is all fine, but why not just change BT_INFO to point to bt_info
> and BT_ERR to bt_err first instead of having this huge patch mixed in
> with the changes. The size measurement should be no different.

I'm with Marcel here, it is not really a good idea to change BT_INFO to
bt_info and BT_ERR to bt_err. I understand that capital letters are not the
standard here but such a change is painful for all Bluetooth developers and I
don't wanna give more trouble to them. I'm ok if we only change bluetooth.h
here.

	Gustavo
