From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: Question on Netlink IPv6 routing table lookup
Date: Thu, 26 Sep 2013 07:36:56 -0300
Message-ID: <52440E48.3030102@gont.com.ar>
References: <52409953.8040208@gont.com.ar> <20130924000453.GB2593@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:40801 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3IZKhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 06:37:19 -0400
In-Reply-To: <20130924000453.GB2593@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Hannes,

On 09/23/2013 09:04 PM, Hannes Frederic Sowa wrote:
> On Mon, Sep 23, 2013 at 04:41:07PM -0300, Fernando Gont wrote:
>> If that's not (currently) possible, should I expect RTA_SRC to work as
>> described above at some point in the future?
> 
> The RTA_SRC attriute matches on sutrees in the ipv6 routing table:
> 
> ip -6 r a default via fe80::1 dev eth0 from 2000::/64
> ip -6 r a default via fe80::2 dev eth0 from 2000:1:/64
> 
> ip -6 r g :: from 2000::
> ip -6 r g :: from 2000:1::
> 
> ...should return different routes. The from parameter is the RTA_SRC
> attribute.

Isn't the "from" the "source network" in /proc/net/ipv6_route? (as
described in <http://www.tldp.org/HOWTO/Linux+IPv6-HOWTO/proc-net.html>)

I have a node with multiple Ethernet interfaces, each of which connected
to a different network where IPv6 Router Advertisements are received...
and the "source network" is set to all-zeros in all cases.

Thanks!

Best regards,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
