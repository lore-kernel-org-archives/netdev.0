From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Fri, 13 Jun 2003 12:50:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16105.44171.178489.492922@robur.slu.se>
References: <16102.9418.43884.336925@robur.slu.se>
	<20030611.234534.52193216.davem@redhat.com>
	<16104.34463.60472.750699@robur.slu.se>
	<20030612.143540.41663883.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, ralph@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030612.143540.41663883.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > But Robert, do you know "why" the dst management doesn't show up in
 > your profiles when you rip-out the rtcache?
 > 
 > It's because to total number of DST entries is so small that they all
 > fit in the cpu cache.  When the rtcache is enabled and we thus have up
 > to "max_size" DST entries in flight at all times, the dst management
 > routines show up very clearly because they have a high probability of
 > missing the cpu cache.
 > 
 > In particular, have a good look at Simon's profiles.  dst_alloc() is
 > quite near the top there.

 Yes and that was the intention to get pretty close to pure slowpath. 
 As a result I/we now appreciate the hash better...

 Cheers.

						--ro
