From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 23:49:46 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.234946.35677224.davem@redhat.com>
References: <20030608234926.GA9453@netnation.com>
	<001001c32e19$81bc7ea0$4a00000a@badass>
	<20030609064719.GA20613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030609064719.GA20613@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Sun, 8 Jun 2003 23:47:19 -0700
   
   Really, though, shouldn't the route cache overhead be fairly small in
   comparison to everything else involved in forwarding?

If GC is just doing dumb things, it is possible.

These costs can be hidden in non-rtcache places in the form of cache
misses and displacement on rtcache objects which can show up as higher
costs in other places.
