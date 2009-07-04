From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sat, 4 Jul 2009 18:03:25 +0300
Message-ID: <200907041803.25436.denys@visp.net.lb>
References: <200907030246.18054.denys@visp.net.lb> <200907041055.24516.denys@visp.net.lb> <m1fxdc8pcl.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39157 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbZGDPDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 11:03:49 -0400
In-Reply-To: <m1fxdc8pcl.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 04 July 2009 18:00:58 Eric W. Biederman wrote:
>
> Problems occur when you have machines with ip addresses that you don't
> have routes to.  How do machines with addresses without routes to them
> get packets from machines in other subnets.
>
> Eric
They are not supposed to communicate then with this Linux host.
But Linux poisoning them by ARP replies.
