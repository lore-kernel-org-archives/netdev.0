From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] cfg80211: make RATE_INFO_BW_20 the default
Date: Thu, 4 May 2017 10:33:32 -0700
Message-ID: <CA+55aFzFAjbAzF4Vda6wzSHt+RL4WW3jXfKuXPcFyi8njXJrnQ@mail.gmail.com>
References: <20170504064230.22058-1-johannes@sipsolutions.net>
 <20170504.111333.814726752020791317.davem@davemloft.net> <1493911002.18881.0.camel@sipsolutions.net>
 <20170504.112257.1601480484804301664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504.112257.1601480484804301664.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 4, 2017 at 8:22 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
>>
>> I figured I'd give Linus to a chance to try or even apply it, but I
>> have no objection to you applying it either. I don't have anything else
>>   yet right now, and sending a pull request for just a single patch
>> would be quite pointless.
>
> Ok, let's give Linus a chance to test the patch.

I'm having trouble recreating the warning. I have no idea why. It only
happened during ten minutes yesterday, and nothing in my wireless
setup has changed.

I wonder if *normally* my setup ends up connecting with a 40MHz band
or something, and I just happened to see the default uninitialized
case once.

I see that Jens reported that the patch works, although I'm wondering
how repeatable it was for him.  The patch obviously looks simple and
seems like an obviously GoodThing(tm) regardless.

                   Linus
