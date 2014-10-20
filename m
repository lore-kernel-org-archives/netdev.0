From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device
 via RTM_LINK
Date: Mon, 20 Oct 2014 11:47:17 +0200
Message-ID: <1413798437.10246.12.camel@jlt4.sipsolutions.net>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
	 <1411075535.2034.5.camel@jlt4.sipsolutions.net>
	 <20141014121627.GA5115@angus-think.lan>
	 (sfid-20141014_142515_817763_5937F980)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141014121627.GA5115-RsE+ugaVo768flhn69MzTw@public.gmane.org> (sfid-20141014_142515_817763_5937F980)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-14 at 15:16 +0300, vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:

> The reason for this was to make possible to change netns for wireless
> dev via 'ip link' too like for 'iw' util. I just think that changing
> namespace for netdev should have the generic way. May be you can suggest
> a better way

That's a respectable goal, but I think you're way overshooting it and
thus getting it wrong. You're changing the semantics from

 "please switch this interface to that other netns"

to
 "please switch this interface *and all others on this HW* to that other
netns"

which is, in my opinion, something so much more unexpected and prone to
breaking people's setups than returning "not supported" here.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
