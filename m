From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 08:56:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.085600.71109220.davem@redhat.com>
References: <20030609195652.E35696@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
	<20030610015311.GB23009@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030610015311.GB23009@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 9 Jun 2003 18:53:12 -0700

   Your CPU use is quite a bit higher than ours.

Yeah, but his faster cpu is all being burnt to a crisp
doing PIO accesses to the 3c59x card.

   I found that once NAPI was happening, userspace seemed to get a
   fairly decent amount of time.

Unfortunately, NAPI won't help him with the current way the 3c59x
driver works.  It needs to provide a way to use MEM I/O before NAPI
would start to be of use to him.
