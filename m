From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Thu, 17 Oct 2002 23:14:32 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210172309160.28084-100000@netcore.fi>
References: <20021017162624.GC16370@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>, <yoshfuji@wide.ad.jp>,
   <torvalds@transmeta.com>, <jagana@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Antti Tuominen <ajtuomin@morphine.tml.hut.fi>
In-Reply-To: <20021017162624.GC16370@morphine.tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Oct 2002, Antti Tuominen wrote:
> Intermediate revision of the specification "Draft 18++" appeared a few
> days ago, which addressed most of the issues with earlier drafts (16,
> 17, 18).  This made it possible to update our code to something usable
> (later than 15).  This patch set has support for most of it.

Sounds great.  Hopefully it slows down a bit from being a moving target.
 
> To Alexey, (and everyone else)
> 
> The patch has been split for easier reading as follows:
> 
> ipv6_tunnel.patch	6over6 tunneling
> network_mods.patch	Modifications to network code and hooks
> mipv6_cn_support.patch	Correspondent node support (+common code)
> mipv6_mn_support.patch	Mobile node support (+common code with HA)
> mipv6_ha_support.patch	Home agent support

I didn't look at these that much, but I'll make two generic observations:

 1) current tunneling (including sanity checks which are, I believe, a bit
non-existant at the moment) should be generalized to handle v6-in-v6 and
v6-in-v4 tunneling anyway.  Not sure if this is the right way, but that's
IMO one priority item.

 2) without IPSEC, there is no way to secure MN-HA traffic.  Therefore I 
think the first priority is being able to support Correspondent Node 
behaviour.

I belive Alexey, Davem et al are best to justify whether this feels like a 
right approach.

Having IPSEC + MIPv6 in 2.6 series would be Really Cool, though :-)

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
