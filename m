From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 1/5] netlink: extended ACK reporting
Date: Wed, 12 Apr 2017 11:30:56 -0400 (EDT)
Message-ID: <20170412.113056.1269483192753304111.davem@davemloft.net>
References: <20170412123408.22012-2-johannes@sipsolutions.net>
        <dbc81431-487b-f218-a4c6-2caa44783d97@cumulusnetworks.com>
        <1492010503.2855.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
        jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1492010503.2855.14.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 12 Apr 2017 17:21:43 +0200

> On Wed, 2017-04-12 at 09:06 -0600, David Ahern wrote:
>> 
>> There was a discussion about side effects of adding strings (bloat,
>> internationalization). Should ATTR_MSG be removed until that is
>> ironed out? Leaving it in suggests it is ok to start adding strings.
> 
> I really do want the strings; this is why I named the struct member
> "_msg" and added the NL_SET_ERR_MSG() macro, that will easily allow
> both making the strings optional with Kconfig (bloat) and collecting
> them into a separate data section (translation).

Yep, this is a long range plan.
