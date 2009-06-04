From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 	802.15.4 devices
Date: Thu, 04 Jun 2009 17:15:17 +0200
Message-ID: <4A27E505.9070108@trash.net>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>	 <1244021964.10665.5.camel@johannes.local>	 <20090603.030911.162861804.davem@davemloft.net>	 <20090603105256.GB20508@doriath.ww600.siemens.net>	 <1244027110.1693.9.camel@johannes.local>	 <20090603122744.GC20508@doriath.ww600.siemens.net>	 <1244124749.22576.71.camel@johannes.local>	 <bc64b4640906040751i3c64c317i4eedb7d53307092a@mail.gmail.com>	 <4A27E448.3040305@trash.net> <bc64b4640906040814m1756ea13s19e20592ecf90e9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bc64b4640906040814m1756ea13s19e20592ecf90e9b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dmitry Eremin-Solenikov wrote:
> 2009/6/4 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>:
>> canceling messages is only necessary in fill functions that are
>> also used for dumps, where as many elements are stuffed in the
>> skb as possible. When the last element doesn't completely fit,
>> its removed again (canceled) and put into the next skb.
> 
> Understood. So you'd suggest just to drop the genlmsg_cancel()
> from the failure call chain?

Yes.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
