From: Ben Greear <greearb@candelatech.com>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Mon, 21 Oct 2002 11:37:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB44966.1070402@candelatech.com>
References: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Theres a 2419 patch that should work for you at:
> http://www.cyberus.ca/~hadi/tulip-2419-napi-nifd.gz

Link does not work for me.  But I got Robert's patch to
work with a small bit of hacking...  (I changed HZ to 1000
and it locked up 10 seconds after I started (pkts were sent,
but nothing received on any port).  However, I restarted,
and it ran all night with very few dropped packets...)

> Also pick a small patch on top of this at:
> http://www.cyberus.ca/~hadi/patch-napi-tulip-20020915

Does not work either...

> 
> Now if you wanna get adventorous why not pick:
> http://www.cyberus.ca/~hadi/tulip-feed.tgz
> You still need that second patch;

Do you have any descriptions of what this feed patch does differently
from other drivers?

> In addition to solve your skb problem pick Roberts latest
> recycling patch at:
> ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/recycle12.pat
> The driver i pointed to above has skb-recycling built in.

I'll give that a try.

Thanks!

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
