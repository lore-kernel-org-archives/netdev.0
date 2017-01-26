From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IPv6-UDP 0x0000 checksum
Date: Thu, 26 Jan 2017 06:45:42 -0800
Message-ID: <1485441942.5145.131.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485437276.14760.3.camel@sipsolutions.net>
         <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_144502_343976_16232A6D) <1485438546.14760.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485438546.14760.7.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-26 at 14:49 +0100, Johannes Berg wrote:

> Oops, sorry - receive. We can only indicate "CHECKSUM_UNNECESSARY",
> nothing more advanced right now, but right now we'd indicate that if
> the packet had 0x0000 in the checksum field, but should've had 0xffff.
> 
> On TX I believe we actually do in HW exactly what your patch just did.

Can you describe the visible effects of this problem ?

Is that because of a conversion we might do later to CHECKSUM_COMPLETE ?
