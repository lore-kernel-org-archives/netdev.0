From: David Miller <davem@davemloft.net>
Subject: Re: Question about /proc/net/netlink mystery
Date: Wed, 20 May 2009 20:54:40 -0700 (PDT)
Message-ID: <20090520.205440.45091399.davem@davemloft.net>
References: <eb3ff54b0905201222t6ecc241bq2168538742b48deb@mail.gmail.com>
	<1242849063.6618.64.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751212AbZEUDyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 23:54:41 -0400
In-Reply-To: <1242849063.6618.64.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 20 May 2009 20:51:03 +0100

> On Wed, 2009-05-20 at 22:22 +0300, Rami Rosen wrote:
>> So it seems that the title should be here different; it should represent
>> the protocol (since s->sk_protocol is assigned
>> the number of the protocol of the netlink socket ;
>> for example, NETLINK_ROUTE is 0, NETLINK_AUDIT is 9, and so on ; (see
>> include/linux/netfilter.h)
>> 
>> So shouldn't it be something like "Proto"?
> 
> Yes, but changing column names in /proc risks breaking the programs that
> read them.

Indeed, it's odd, but like others I don't think we can change it
at this point.
