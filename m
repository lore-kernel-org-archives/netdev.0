From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: Remove warn_if_extra_mangle
Date: Tue, 04 Nov 2008 14:36:39 +0100
Message-ID: <49104FE7.7070509@trash.net>
References: <490F727C.6020705@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org
To: Simon Arlott <simon@arlott.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41509 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbYKDNgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 08:36:46 -0500
In-Reply-To: <490F727C.6020705@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Arlott wrote:
> In net/ipv4/netfilter/nf_nat_rule.c, the function warn_if_extra_mangle was added 
> in commit 5b1158e909ecbe1a052203e0d8df15633f829930 (2006-12-02). I have a DNAT 
> target in the OUTPUT chain than changes connections with dst 2.0.0.1 to another 
> address which I'll substitute with 66.102.9.99 below.
> 
> On every boot I get the following message:
> [  146.252505] NAT: no longer support implicit source local NAT
> [  146.252517] NAT: packet src 66.102.9.99 -> dst 2.0.0.1
> 
> As far as I can tell from reading the function doing this, it should warn if the 
> source IP for the route to 66.102.9.99 is different from 2.0.0.1 but that is not 
> the case. It doesn't make sense to check the DNAT target against the local route 
> source.
> 
> Either the function should be changed to correctly check the route, or it should 
> be removed entirely as it's been nearly 2 years since it was added.

Removing it sounds fine to me. Applied, thanks.
