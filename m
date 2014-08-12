From: Daniel Gimpelevich <daniel-R/FLGEdV95bo9U+Z1CfBt0SU0eOFXohjCypLqA8HKkk@public.gmane.org>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Mon, 11 Aug 2014 17:01:06 -0700
Message-ID: <1407801666.28221.84.camel@chimera>
References: <1407780269.28221.63.camel@chimera>
	 <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org>
	 <1407789645.28221.68.camel@chimera>
	 <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org>
	 <1407791075.28221.74.camel@chimera>
	 <28066DB2-9EA9-4748-9C89-D3FBD3EC51F5@holtmann.org>
	 <1407798738.28221.81.camel@chimera>
	 <52896C9C-8560-4CE4-A1FB-C896D766EC87@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org Wireless"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52896C9C-8560-4CE4-A1FB-C896D766EC87-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-08-11 at 16:56 -0700, Marcel Holtmann wrote:
> the way I read the nl80211 code is that the NL80211_CMD_NEW_INTERFACE
> requires a wiphy device to be specified. And that is actually just a
> number. So I have no idea what the MAC has to here.
> 
OpenWrt finds a wiphy by its MAC.

> Why does the wiphy need to know the MAC if it is always specified from
> userspace when actually creating the new netdev interface. Works for
> P2P devices, so why wouldn't it work for access point and station
> mode?
> 
A MAC can be specified for the netdev, but it is assigned to a wiphy
identified by its MAC.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
