From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: netdev level filtering? perhaps pushing socket filters down?
Date: Thu, 16 Mar 2017 23:44:04 +0100
Message-ID: <1489704244.3930.7.camel@sipsolutions.net>
References: <1489703635.3930.5.camel@sipsolutions.net>
         <58CB1714.8000305@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <58CB1714.8000305-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> Attach at just above the driver, before it ever gets to
> stations/vdevs, and ignore radiotap headers and/or add special
> processing for metadata like rx-info?

That'd be a different feature, perhaps more like XDP.

There anyway is no radiotap header at that point, but not changing
whether or not it makes it to other virtual interfaces is actually not
what we're looking for here at all.

johannes
