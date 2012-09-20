From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:54:21 +0200
Message-ID: <1348145661.4161.34.camel@jlt4.sipsolutions.net>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
	 <1348145269.4161.28.camel@jlt4.sipsolutions.net>
	 <CANn89iLksBMJ=Ep+VcPSAOPzqst70hk8hR5=mGte2vSx=49zUA@mail.gmail.com>
	 <1348145450.4161.31.camel@jlt4.sipsolutions.net>
	 <CANn89iLudX29yU8ziNyN+8gN3b2L55L9m5p6ob_wnfZ3fp_TDg@mail.gmail.com>
	 (sfid-20120920_145113_728996_FFF92D50)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANn89iLudX29yU8ziNyN+8gN3b2L55L9m5p6ob_wnfZ3fp_TDg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20120920_145113_728996_FFF92D50)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-20 at 14:51 +0200, Eric Dumazet wrote:
> So its using a RAW socket ?

Yes:

socket(PF_PACKET, SOCK_RAW, htons(ETH_P_EAPOL))

johannes

> On Thu, Sep 20, 2012 at 2:50 PM, Johannes Berg
> <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> > On Thu, 2012-09-20 at 14:48 +0200, Eric Dumazet wrote:
> >> Or its a buggy protocol ?
> >>
> >> IP/UDP/TCP definitely works, but maybe another protocol assumes its
> >> header is in skb->head
> >
> > It could be, I think it failed either on EAPOL (which is just userspace
> > registering a protocol socket) or DHCP (same?)
> >
> > johannes
> >
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
