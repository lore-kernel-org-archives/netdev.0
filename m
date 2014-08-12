From: Jonas Gorski <jogo-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Tue, 12 Aug 2014 10:43:27 +0200
Message-ID: <CAOiHx=mWkvOf=An=TzWDidK2o4+KGQmz8MAHNo3rSuwbBzUWEg@mail.gmail.com>
References: <1407780269.28221.63.camel@chimera> <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org>
 <1407789645.28221.68.camel@chimera> <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org>
 <1407791075.28221.74.camel@chimera> <28066DB2-9EA9-4748-9C89-D3FBD3EC51F5@holtmann.org>
 <1407798738.28221.81.camel@chimera> <52896C9C-8560-4CE4-A1FB-C896D766EC87@holtmann.org>
 <1407801666.28221.84.camel@chimera> <70001DBA-E1CE-49D6-9A37-6F7CE31B61E6@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Gimpelevich <daniel-R/FLGEdV95bo9U+Z1CfBt0SU0eOFXohjCypLqA8HKkk@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org Wireless"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <70001DBA-E1CE-49D6-9A37-6F7CE31B61E6-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 12, 2014 at 9:59 AM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> wrote:
> Hi Daniel,
>
>>> the way I read the nl80211 code is that the NL80211_CMD_NEW_INTERFACE
>>> requires a wiphy device to be specified. And that is actually just a
>>> number. So I have no idea what the MAC has to here.
>>>
>> OpenWrt finds a wiphy by its MAC.
>
> maybe that is the first problem right there. I see that over sysfs you get phy80211/macaddress. However if you do a dump via NL80211_CMD_GET_WIPHY then you do not have the MAC address there.

OpenWrt nowadays uses the device path in sysfs/devices to identify
wiphys, not the mac anymore (e.g 'pci0000:00/0000:00:01.0/ssb0:0').


Jonas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
