From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: (diet-)FIB alternative fib_hlist.c
Date: Fri, 6 May 2005 13:31:14 +0200
Message-ID: <17019.21890.234387.549229@robur.slu.se>
References: <17016.62444.34282.625407@robur.slu.se>
	<427A7A09.4060900@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
        Jens.Laas@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Tomt <andre@tomt.net>
In-Reply-To: <427A7A09.4060900@tomt.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andre Tomt writes:

 > > Probably we soon want to specify differnt lookup schemes for different 
 > > tables say for local table fib_hash or fib_hlist. While for large main table
 > > fib_hash2/fib_trie would be better option.
 > 
 >  From a distribution[1] point of view, a boot time option would be much 
 > better than choosing at compile time. Boot time plus a kconfig multiple 
 > selection list would be even better. Another perhaps even more user 
 > friendly option would be setting it runtime using f.ex. iproute, but I 
 > guess that could end up messy..

 Yes I'll guess kernel config would be the first step. Also we need to
 find out if there are any useful options to current FIB. Which is very
 general purpose.

 Anyway we have a cleaner interface to FIB also we have some new FIB options.
 Which should be a step forward and an advantage for linux and will hopefully 
 lead to more development and understanding and so that Linux will used for 
 development in this area. We will also lead to better understand the dst 
 hash and FIB trade off.

 Experiences from tests or use are very welcome.

 Cheers.
					--ro
