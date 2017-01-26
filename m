From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IPv6-UDP 0x0000 checksum
Date: Thu, 26 Jan 2017 07:24:36 -0800
Message-ID: <1485444276.5145.133.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485437276.14760.3.camel@sipsolutions.net>
         <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_144502_343976_16232A6D) <1485438546.14760.7.camel@sipsolutions.net>
         <1485441942.5145.131.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_154545_190303_B1FB80BF) <1485442164.14760.11.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485442164.14760.11.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-26 at 15:49 +0100, Johannes Berg wrote:

> Unfortunately, I haven't been able to actually test this yet. I also
> didn't find the code that would drop frames with CSUM 0 either, so I'm
> thinking - for now - that if all the csum handling is skipped, dropping
> 0 csum frames would also be, and then we'd accept a frame we should
> actually have dropped.
> 
> I'll go test this I guess :)
> 
> Any pointers to where 0 csum frames are dropped?

Probably in udp6_csum_init()
