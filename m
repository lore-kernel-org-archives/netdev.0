From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device via RTM_LINK
Date: Mon, 20 Oct 2014 12:46:58 +0200
Message-ID: <128188DF-5A9B-47A5-8A89-974CF7CF9064@holtmann.org>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com> <1411075535.2034.5.camel@jlt4.sipsolutions.net> <20141014121627.GA5115@angus-think.lan> <1413798437.10246.12.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1413798437.10246.12.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

>> The reason for this was to make possible to change netns for wireless
>> dev via 'ip link' too like for 'iw' util. I just think that changing
>> namespace for netdev should have the generic way. May be you can suggest
>> a better way
> 
> That's a respectable goal, but I think you're way overshooting it and
> thus getting it wrong. You're changing the semantics from
> 
> "please switch this interface to that other netns"
> 
> to
> "please switch this interface *and all others on this HW* to that other
> netns"
> 
> which is, in my opinion, something so much more unexpected and prone to
> breaking people's setups than returning "not supported" here.

this is just me thinking out loud and by no means any recommendation on doing this. I am not even sure this is a good idea.

Maybe relaxing the check and allow ip link to move a wireless netdev into a namespace (and having the wiphy follow) could be allowed if it is the only netdev or the original wlan0 that each wiphy creates. I really do not know if this is worth it, but for some simpler container cases it could be beneficial if RTNL can be used instead of having to go through nl80211.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
