From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bluetooth 6LoWPAN and routing
Date: Thu, 24 Oct 2013 13:55:06 +0200
Message-ID: <20131024115506.GD15744@order.stressinduktion.org>
References: <5268C214.2040307@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54773 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab3JXLzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 07:55:08 -0400
Content-Disposition: inline
In-Reply-To: <5268C214.2040307@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, Oct 24, 2013 at 09:45:40AM +0300, Jukka Rissanen wrote:
> I have been prototyping with BT 6LoWPAN support (using this draft 
> http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12 as a reference). I 
> sent first version yesterday to linux-bluetooth ml 
> http://thread.gmane.org/gmane.linux.bluez.kernel/39394
> 
> In this current prototype, after the BT connection is created, the code 
> set ups the virtual network interface, sets the IPv6 LL address for it 
> and creates an IPv6 route to peer (the BT 6LoWPAN connections are 
> point-to-point connections). I am using ip6_route_add() function from 
> net/ipv6/route.c file to do that. Unfortunately that function is not 
> exported so I GPL exported it for this prototype. Will this kind of 
> export accepted in upstream or should I figure out some other way to 
> create the desired route?

I am very confident that a patch making ip6_route_add gpl exported will be
accepted.

Greetings,

  Hannes
