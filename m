From: Andre Tomt <andre@tomt.net>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 09:04:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414FD272.6010309@tomt.net>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> As a result, on systems with large networks (think of even less than 16
> bit netmasks!) the neighbour table can grow quite significantly,
> especially if some jerk runs pktgen with random destinations, and we
> start expiring 'real' neighbours in favour of incomplete ones.  

Or just regular worms/viruses traversing the Internet. Usually in setups 
I've seen, the arp cache overflows within seconds even on "smaller" 
prefixes like /21. The networks did get redesigned properly as a result 
of this however.
