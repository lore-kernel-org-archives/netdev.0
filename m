From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 19 May 2003 18:14:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519.181405.35017608.davem@redhat.com>
References: <Pine.LNX.4.51.0305191408490.1795@ns.istop.com>
	<20030519154852.I39024@shell.cyberus.ca>
	<20030520011053.GB10419@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030520011053.GB10419@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 19 May 2003 18:10:53 -0700
   
   I doubt we have been the
   target of any hashing-specific attacks.

I bet you have been, the weakness in the hash has been very well
publicized and the script kiddies aren't using the truly random
version of the attacks anymore.  Just google for juno-z.101f.c, this
(or some derivative) is the DoS people attack program are actually
using.

It was the only major place where the routing cache was weak
performance wise.
