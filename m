From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 09:29:18 +0200
Message-ID: <1491895758.31620.4.camel@sipsolutions.net>
References: <20170411065700.2623-1-johannes@sipsolutions.net>
         <20170411065700.2623-2-johannes@sipsolutions.net>
         <20170411071900.GC1976@nanopsycho> (sfid-20170411_091902_806901_2B2253F7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170411071900.GC1976@nanopsycho> (sfid-20170411_091902_806901_2B2253F7)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-04-11 at 09:19 +0200, Jiri Pirko wrote:
> 
> > +	NUM_NLMSGERR_ATTRS,
> 
> According to the rest of the uapi, this should be rather named:
> 	__NLMSGERR_ATTR_MAX

nl80211 uses NUM_ so I guess that's a matter of convention, but I can
change that I guess.

> > 		if (err || (nlh->nlmsg_flags & NLM_F_ACK))
> > -			netlink_ack(skb, nlh, err);
> > +			netlink_ack(skb, nlh, err, NULL);
> 
> Wouldn't it make sense to leave netlink_ack as is and add
> netlink_ack_ext for those who need to pass non-null?

I thought about it, but didn't really see much point. The churn isn't
super big (a dozen callers or so), and I thought it makes sense to
point out to the users that there's something here.

johannes
