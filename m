From: Artem Bityutskiy <artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Fri, 22 Mar 2013 09:01:53 +0200
Message-ID: <1363935713.14966.118.camel@sauron.fi.intel.com>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 (sfid-20120917_163617_677167_0B529F43) <1363894451.8181.4.camel@jlt4.sipsolutions.net>
Reply-To: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: patrik.flykt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363894451.8181.4.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-21 at 20:34 +0100, Johannes Berg wrote:
> On Mon, 2012-09-17 at 17:41 +0300, Artem Bityutskiy wrote:
> 
> > OK, finally I got it. After 3 days of hardcore intelligent bisecting
> >         I've found out that tethering in 3.5 works for me if I revert
> > these 2
> >         patches:
> >         
> >             56138f5 iwlwifi: dont pull too much payload in skb head
> 
> I got back to this for a customer running 3.5, and after many failed
> attempts realized that you have to have iptables for this problem to
> actually happen. I reverse-bisected that the *fix* is
> 6caab7b0544e83e6c160b5e80f5a4a7dd69545c7, in 3.7.
> 
> Is there still any stable kernel 3.5/3.6 (or possibly before, though for
> iwlwifi before doesn't matter) that this should be applied to?

Hi Johannes,

thanks for remembering about this. We've switched to the 3.8 kernel
recently, and we are pulling stable kernels in regularly. Now we are
at 3.8.3.

-- 
Best Regards,
Artem Bityutskiy

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
