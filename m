From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Cannot re-enable 'auto' for IPv6 link local?
Date: Wed, 25 Sep 2013 00:57:00 +0200
Message-ID: <20130924225700.GC4446@order.stressinduktion.org>
References: <5242181A.6090300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48737 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab3IXW5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 18:57:01 -0400
Content-Disposition: inline
In-Reply-To: <5242181A.6090300@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 03:54:18PM -0700, Ben Greear wrote:
> At one time, I'm fairly certain this worked, but not having much
> luck in a hacked 3.9.11+ kernel:
> 
> The goal is to enable the link-local address to be auto-configured.
> At start of this, there is no /proc/sys/net/ipv6/config/eth30 dir
> because all IPv6 addrs were removed (I suppose).
> 
> # ./local/sbin/ip -6 addr add 2345::18 dev eth30
> # echo 1 > /proc/sys/net/ipv6/conf/eth30/autoconf
> # cat /proc/sys/net/ipv6/conf/eth30/autoconf
> 1
> # ./local/sbin/ip -6 addr del 2345::18 dev eth30
> # cat /proc/sys/net/ipv6/conf/eth30/autoconf
> cat: /proc/sys/net/ipv6/conf/eth30/autoconf: No such file or directory
> 
> 
> What is the proper way to turn on ipv6 auto configuration?

This issue is fixed by commit 876fd05ddbae03166e7037fca957b55bb3be6594 ("ipv6:
don't disable interface if last ipv6 address is removed").

Greetings,

  Hannes
