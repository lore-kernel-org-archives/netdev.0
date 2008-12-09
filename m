From: Colin Alston <colin.alston@thusa.co.za>
Subject: Re: [Shorewall-devel] Fwd: iproute weight balancing problem with
 youtube
Date: Tue, 09 Dec 2008 20:30:40 +0200
Message-ID: <493EB950.8020203@thusa.co.za>
References: <200812091803.35682.frahm@sybuca.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shorewall-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcs-gw.bulwer.thusa.net ([196.212.55.130]:51666 "EHLO
	siza.bulwer.thusa.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753569AbYLITWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 14:22:19 -0500
In-Reply-To: <200812091803.35682.frahm@sybuca.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008/12/09 07:03 PM Markus Frahm wrote:
> Dear Stephen Hemminger,
> we have found a problem with ip route and multiple internet connections using 
> the ip route 'weight' option to balance the traffic of a NAT firewall between 
> several lines. Internet sites like 'youtube' show videos only with 50% 
> probability because youtube and similar sites demand several connections (for 
> the web site and the flash stream) to come from the same source IP. Is there a 
> simple solution for this problem for example to increase the time in the 
> balancing algorithm or a cache for source IPs? 
> Regards
>   

Should not be a problem. YouTube uses a single stream for buffering and 
there should not be any conflict between a change in source address with 
the request for the flash applet and the stream. HTTP does not work that 
way... There are some protocols that do, in which case there is contrac 
to solve that problem, if there were a bug it would be in contrac so you 
should raise the issue on the Netfilter lists.

I have personally used Shorewall in such a configuration (we are 
designing a product at the moment for that exact purpose) and have not 
seen any issues. Are you sure this is not a packet loss issue on one of 
the upstreams?
