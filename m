From: Carlos Carvalho <carlos@fisica.ufpr.br>
Subject: Re: Memory usage for ip_conntrack
Date: Sat, 19 Jul 2003 21:10:40 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16153.56832.379224.202834@fisica.ufpr.br>
References: <1058558848.2674.88.camel@mentor.gurulabs.com>
	<1058563690.26030.23.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1058563690.26030.23.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Josefsson (gandalf@wlug.westbo.se) wrote on 18 July 2003 23:28:
 >> If I echo 102400 > /proc/sys/net/ipv4/ip_conntrack_max, what is my worst
 >> case memory usage?
 >
 >Don't do this. This will increase the maximum number of connections it
 >will track, but not the number of buckets. Which means that it will be
 >slower due to longer collision-chains. Instead increase the number of
 >buckets. modprobe ip_conntrack hashsize=131072 (or any number here.

How can we increase the number of buckets with a monolithic kernel?
