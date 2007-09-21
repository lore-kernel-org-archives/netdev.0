From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: wrong arp query with policy routing
Date: Fri, 21 Sep 2007 14:56:55 +0200
Message-ID: <BAY103-DAV13C9EFE297F41FFC4007EAB2BB0@phx.gbl>
References: <BAY103-DAV2BC129A14C4A29986CC0CB2B80@phx.gbl> <BAY103-DAV12BF0DF9E47B1577FB9814B2B90@phx.gbl> <46F29741.2030505@redhat.com> <BAY103-DAV1014588479A3FF5B66EEDDB2BB0@phx.gbl> <1190377540.4261.58.camel@localhost>
Cc: "Chuck Ebbert" <cebbert@redhat.com>, <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s35.bay0.hotmail.com ([65.54.246.235]:58378 "EHLO
	bay0-omc3-s35.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751449AbXIUM5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:57:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:

> On Fri, 2007-21-09 at 11:08 +0200, Marco Berizzi wrote:
>
> > thanks for the reply.
> > I have tried to 'echo 1 > /proc/sys/net/ipv4/conf/eth0',
> > but the 'arp whos-has' behaviour doesn't change.
> > Other hints?
>
> Give a man a fish and he'll eat for a day....
>
> Documentation/networking/ip-sysctl.txt

Thanks for the tip Jamal.
I have done a 'grep -i arp' on that file and
arp_announce should do the trick. But I always
get the same behaviour, after:

echo 2 > /proc/sys/net/ipv4/conf/eth0/arp_announce
echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce

Here is:
14:43:26.096574 00:01:02:ad:db:82 > ff:ff:ff:ff:ff:ff, ethertype ARP
(0x0806),
length 42: arp who-has 1.1.1.254 tell 172.16.1.247

Here is my 'ip a s' output:
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
qlen 1000
    link/ether 00:01:02:ad:db:82 brd ff:ff:ff:ff:ff:ff
    inet 172.16.1.247/23 brd 172.16.1.255 scope global eth0
    inet 1.1.1.1/32 scope global eth0



