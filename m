From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: A problem with a large static arp table
Date: Thu, 01 Jul 2004 11:12:46 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088644366.8180.2.camel@bach>
References: <1835705734.20040630181449@techas.lt>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roman Zagustin <zagustin@techas.lt>
In-Reply-To: <1835705734.20040630181449@techas.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-01 at 01:14, Roman Zagustin wrote:
> Hello!

Hi,

	Not really my area; pinging netdev to see if they can help.

> I have a router with >800 static ip/mac records.
> It does not work :(
> With small table it is fine.
> The kernel is 2.6 (tried with different patches and versions
>  2.4 - the same)
> 
> Just for example(real):
>  
> root@stargate:/proc/sys/net/ipv4/neigh/default# arp -n|grep 172.16.3.230
> 172.16.3.230             ether   00:50:04:6C:50:9E   CM                    eth3
> root@stargate:/proc/sys/net/ipv4/neigh/default#
> root@stargate:/proc/sys/net/ipv4/neigh/default# tcpdump -i eth3 host 172.16.3.230  -e
> tcpdump: listening on eth3
> 15:38:10.660144 0:6:29:ee:c3:d8 0:2:b3:b4:34:e2 ip 448: 172.16.3.230.1060 > medium.cs.microlink.lt.http: P 1268207798:1268208192(394) ack 3537529644 win 64240 (DF)
> 15:38:10.674698 0:6:29:ee:c3:d8 0:2:b3:b4:34:e2 ip 453: 172.16.3.230.1077 > medium.cs.microlink.lt.http: P 1279539300:1279539699(399) ack 2683450794 win 63095 (DF)
> 
> There are no errors/warnings in the log files about neighbour table.
> 
> >From the server I can't ping the 172.16.3.230, but it can ping the
> server. In general, server do not check the ip/mac table at all
> when forwarding received packets.
> 
> I don't know where is the problem :(
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell
