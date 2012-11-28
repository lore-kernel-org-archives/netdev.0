From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Wed, 28 Nov 2012 18:30:37 -0500 (EST)
Message-ID: <20121128.183037.1780631404801131036.davem@davemloft.net>
References: <22884633.2468.1354092935228.JavaMail.driesdw@sahwcmp0020>
	<14515182.2480.1354093791878.JavaMail.driesdw@sahwcmp0020>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: dries.dewinter@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <14515182.2480.1354093791878.JavaMail.driesdw@sahwcmp0020>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dries De Winter <dries.dewinter@gmail.com>
Date: Wed, 28 Nov 2012 10:09:55 +0100 (CET)

> I propose a patch which allows to mark a dst_entry as "non-reroutable".
> icmp6_dst_alloc() (used by ndisc and MLD implementation) will always mark the
> allocated dst_entry as such. A check is added to netfilter (IPv6-only) so
> packets heading for a non-reroutable destination are never rerouted.

What about addrconf_dst_alloc()?  Shouldn't it have this new flag set
as well?

Regardless of the answer to that question, it should be explained
in the commit message.

Thanks.

