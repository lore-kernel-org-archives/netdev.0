From: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 13:51:55 +0200
Message-ID: <877hr5nkx0.fsf@purkki.valot.fi>
References: <87k4v5nuej.fsf@purkki.valot.fi> <4B5ED254.7010104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B5ED254.7010104-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> (Patrick McHardy's message of "Tue\, 26 Jan 2010 12\:30\:28 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> writes:

>> Solution 2: SO_PRIORITY with values 256-263
>
> You can actually encode any class handle in SO_PRIORITY, all classful
> qdiscs support classification based on this.

But what values should I use in an application? There seems to n+1
different ways to do it, but they all would be specific to my own
setup.

I'm after a universal solution, so that there is no need to modify
applications every time. I would assume that we have a set of rules
for this. If not, we definitely need one.

Let's take a bittorrent client as an example. The traffic it generates
is not important and it doesn't matter if bittorrent packets have
lower priority compared to other streams. What SO_PRIORITY value
should all bittorrent clients to use to mark their packets as low
priority (for example background class from IEEE 802.1d Annex G).

Another example is a VoIP application. The packets need to have as low
delay as possible, so they need to be prioritised very high (for
example voice class from 802.1d). What value should such application
use?

Or should applications use something else than SO_PRIORITY?

Any help is greatly welcomed here :)

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
