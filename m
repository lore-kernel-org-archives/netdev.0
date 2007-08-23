From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Thu, 23 Aug 2007 09:01:51 -0700
Message-ID: <1187884912.32738.24.camel@localhost>
References: <1187808408.4314.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4422 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbXHWQHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 12:07:40 -0400
In-Reply-To: <1187808408.4314.15.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-22 at 20:46 +0200, Johannes Berg wrote:
> The two different wireless code bases both define macros to ease
> printing MAC addresses:

There are also several different uses of the equivalent of

	printk("%02x",addr[0])
	for (i=1; i<6; i++)
		printk(":%02x",addr[i]);

to print an ethernet MAC address.

http://www.uwsg.iu.edu/hypermail/linux/net/0602.1/0002.html

As not all device MAC addresses are 6 bytes, colon separated,
perhaps an appropriate ethernet/tr MAC designation is EUI48.

http://standards.ieee.org/regauth/oui/tutorials/EUI48.html

