From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: fix bond_option_mode_set warning
Date: Tue, 15 Jul 2014 16:13:49 +0200
Message-ID: <53C5371D.9060003@redhat.com>
References: <1405433337-8806-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbaGOOTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 10:19:24 -0400
In-Reply-To: <1405433337-8806-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 04:08 PM, Nikolay Aleksandrov wrote:
> During the conversion to "static" functions this one got left out, only its
> prototype was converted, thus resulting in:
> drivers/net/bonding//bond_options.c:674:5: warning: symbol
> 'bond_option_mode_set' was not declared. Should it be static?
> 
> Fix it by making it static and also break the line in two as it was too
> long.
> 
> CC: Stephen Hemminger <stephen@networkplumber.org>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

Just FYI, I targeted this at net-next as it's more cosmetic and there aren't any
real side-effects because of it. In case you decide it's more appropriate for
-net, the commit that did this was:
f3253339a47f ("bonding: options handling cleanup")

and I tested that this patch applies cleanly to -net, so it's fit for there too.

Cheers,
 Nik
