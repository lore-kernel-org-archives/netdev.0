From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Wed, 03 Jun 2009 03:09:11 -0700 (PDT)
Message-ID: <20090603.030911.162861804.davem@davemloft.net>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>
	<1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
	<1244021964.10665.5.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244021964.10665.5.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 03 Jun 2009 11:39:24 +0200

> On Wed, 2009-06-03 at 13:33 +0400, Dmitry Eremin-Solenikov wrote:
> 
>> +enum {
>> +	__IEEE802154_COMMAND_INVALID,
>> +
>> +	IEEE802154_ASSOCIATE_REQ,
>> +	IEEE802154_ASSOCIATE_CONF,
>> +	IEEE802154_DISASSOCIATE_REQ,
>> +	IEEE802154_DISASSOCIATE_CONF,
>> +	IEEE802154_GET_REQ,
>> +	IEEE802154_GET_CONF,
>> +/* 	IEEE802154_GTS_REQ, */
>> +/* 	IEEE802154_GTS_CONF, */
>> +	IEEE802154_RESET_REQ,
>> +	IEEE802154_RESET_CONF,
>> +/* 	IEEE802154_RX_ENABLE_REQ, */
>> +/* 	IEEE802154_RX_ENABLE_CONF, */
> 
> This is a recipe for disaster. Somebody will come along and uncomment
> things. Why this is bad, I leave as an exercise for the reader.

Right, it changes the other request numbers and breaks userspace.

Dmitry you have to pick these numbers as fixed numbers now and do
so in such a way that they will remain unchanged forever because
they are part of the user visible interface.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
