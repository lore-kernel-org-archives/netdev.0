From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Fri, 13 Jun 2003 12:40:23 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16105.43543.826589.672148@robur.slu.se>
References: <004f01c32ebe$b4bd88d0$4a00000a@badass>
	<20030609221911.GF11509@netnation.com>
	<16101.4136.328760.955758@robur.slu.se>
	<20030612.232114.71088346.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, sim@netnation.com, xerox@foonet.net,
	hadi@shell.cyberus.ca, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030612.232114.71088346.davem@redhat.com>
List-Id: netdev.vger.kernel.org


David S. Miller writes:
 >    From: Robert Olsson <Robert.Olsson@data.slu.se>
 >    Date: Tue, 10 Jun 2003 00:54:32 +0200
 >     
 >     I'm about to propose some stats even for hash spinning.... 
 > 
 > Do you mind if I apply this?  It looks fine.

 No please do. There is an updated rtstat already.

 > Next, we should put similar metrics into fib_hash.c

 Yes.

 Also "candidate" selection in __rt_hash_shrink can be done in 
 rt_intern_hash. We avoid an the extra spinning over the hash chain. 
 Eventually we can save here and have the candidate always ready.

 Cheers.

					--ro
