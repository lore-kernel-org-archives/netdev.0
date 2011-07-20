From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [RFC] iproute2, ifindex option
Date: Wed, 20 Jul 2011 18:54:44 +0300
Message-ID: <8dcbf9cb55d19da1e7f849d11d8eb216@visp.net.lb>
References: <f91760b4ff170e4bdbd46f40822dd95e@visp.net.lb>
 <20110720083753.2b8de970@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34893 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab1GTPyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:54:47 -0400
In-Reply-To: <20110720083753.2b8de970@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Wed, 20 Jul 2011 08:37:53 -0700, Stephen Hemminger wrote:
>
> If caching is a problem, I would rather just get rid of the cache 
> altogether.
> There are a number of other places where it is a problem as well.
 It is good, but it must be controlled. Also people put some efforts to 
 improve it...
 Before i did custom patch to "trash" the cache, but after cache 
 improved i should rewrite it. If required, i can make cache behavior 
 changeable (on,off,flush ?).
 Will it help for you too?

 I think ifindex is good anyway, because sometimes it is better to refer 
 to specific ppp interface by ifindex.

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
