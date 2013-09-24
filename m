From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Question on Netlink IPv6 routing table lookup
Date: Tue, 24 Sep 2013 02:04:53 +0200
Message-ID: <20130924000453.GB2593@order.stressinduktion.org>
References: <52409953.8040208@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46562 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab3IXAEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 20:04:55 -0400
Content-Disposition: inline
In-Reply-To: <52409953.8040208@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 04:41:07PM -0300, Fernando Gont wrote:
> If that's not (currently) possible, should I expect RTA_SRC to work as
> described above at some point in the future?

The RTA_SRC attriute matches on sutrees in the ipv6 routing table:

ip -6 r a default via fe80::1 dev eth0 from 2000::/64
ip -6 r a default via fe80::2 dev eth0 from 2000:1:/64

ip -6 r g :: from 2000::
ip -6 r g :: from 2000:1::

...should return different routes. The from parameter is the RTA_SRC
attribute.

Greetings,

  Hannes
