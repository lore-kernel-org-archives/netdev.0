From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 3 Jul 2009 23:37:15 +0300
Message-ID: <200907032337.16065.denys@visp.net.lb>
References: <200907030246.18054.denys@visp.net.lb> <200907031402.34941.denys@visp.net.lb> <20090703.132005.113285172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:37525 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbZGCUhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 16:37:36 -0400
In-Reply-To: <20090703.132005.113285172.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 July 2009 23:20:05 David Miller wrote:

> I really never should have applied your initial patch, I severely
> regret it.  Thanksfully it's reverted now and we can look into
> this issue more properly.
If it was said before...

Then maybe i will try to do some new sysctl value?

By default it will be old behavior, but it can be changed to new on user 
choice.

Let's say 

net.ipv4.arp_proxy_gateway 
net.ipv4.arp_proxy_gratuitous
