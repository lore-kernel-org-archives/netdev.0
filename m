From: "Nick Kossifidis" <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Wed, 25 Jun 2008 03:56:21 +0300
Message-ID: <40f31dec0806241756j2916da61n42e6a7b5ea556ea7@mail.gmail.com>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi>
	 <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com>
	 <1214298259.8967.260.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Adrian Bunk" <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1214298259.8967.260.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2008/6/24 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
>
>> You can currently only get away living without it if you are just
>> using iwl3945 or iwl4965 as they provide their own rate control
>> algorithms. In the future if other vendor drivers are added with their
>> own rate control algorithm this list grows.
>
> FWIW, I would like to see those algorithms be supported as part of
> mac80211 and not be internal like iwlwifi hacked them on, and have some
> sort of feature negotiation between the hardware and the RC algorithm
> when choosing one.
>
> johannes
>

I also agree on that, this way we can eg. port samplerate or minstrel
from MadWiFi to mac80211 for any card that can do multirate
transmitions for example, not only Atheros cards.

We need however a fallback algorithm compiled in by default if we go
that way because the user might not know what algorithms are
compatible with his card during kernel configuration. I guess PID is
generic enough for this.

Also ideally the user should be able to change rate control algorithm
during runtime (without the need to reload the driver), i think having
rate control inside mac80211 makes it easier.


-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
