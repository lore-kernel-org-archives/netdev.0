From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 09:37:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.093755.51688774.davem@redhat.com>
References: <001801c32e50$57ef0750$4a00000a@badass>
	<20030608.232827.88487519.davem@redhat.com>
	<20030609092327.41899cb5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, hadi@shell.cyberus.ca, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030609092327.41899cb5.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 9 Jun 2003 09:23:27 -0700

   Has anyone looked into using Judy array's to speedup the route
   cache.   HP has opened it up (see
   http://sourceforge.net/projects/judy ) and it should have better
   scaling for these type of attacks.
   
Like all such seemingly promising schemes, insert/retrieve are
optimized at the expense of delete.

I normally don't even look at such algorithms anymore, they all
are amazing if you only build tables and look for things in them
but are unusable when O(1) insert/delete/lookup are absolutely
required.
