From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: (usagi-users 02099) IPv6 packet forging
Date: Mon, 20 Jan 2003 12:53:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15915.58160.182541.806936@robur.slu.se>
References: <Pine.LNX.4.51.0301181523070.3466@trantor.ferrara.linux.it>
	<20030119.010908.127619438.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, mauro@deepspace6.net, ds6-devel@deepspace6.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030119.010908.127619438.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= writes:
 > In article <Pine.LNX.4.51.0301181523070.3466@trantor.ferrara.linux.it> (at Sat, 18 Jan 2003 15:54:12 +0100 (CET)), Mauro Tortonesi <mauro@deepspace6.net> says:
 > 
 > > packets on the net i have used link layer sockets, but i'd like to know if
 > > there are more portable ways to perform the same task. do you know if
 > 
 > How about libpcap?
 > 
 > --yoshfuji
 > 


 FYI.
 pktgen has been added some basic ipv6 send support. Not easy portable since 
 it's Linux module. Anyway it should have some merits due to it's ability to 
 generate very high loads.

 ftp://robur.slu.se:/pub/Linux/net-development/pktgen-testing/
 (Haven't got much of response from any testers sofar)

 It brings up the question of any support for address ipv6 conversion functions
 in kernel? ipv4 has at least in_aton. (net/utils.c)

 pktgen uses scan_ip6, fmt_ip taken from dietlibc to get some minimal inet_pton,
 inet_ntop functionality. 

 Cheers.
						--ro
