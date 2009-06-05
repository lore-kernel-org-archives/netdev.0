From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 5 Jun 2009 15:10:10 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906051508300.17010@fbirervta.pbzchgretzou.qr>
References: <20090604162212.GA24661@ioremap.net> <4A290767.6080202@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:48682 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZFENKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 09:10:08 -0400
In-Reply-To: <4A290767.6080202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2009-06-05 13:54, Patrick McHardy wrote:
>> +
>> +		if (optsize > sizeof(opts))
>> +			optsize = sizeof(opts);
>
> How can this happen? The doff field can only represent up to 40
> bytes of option length.

Forged packets?

>> +	printk(KERN_INFO "Started passive OS fingerprint matching module.\n");
>
> Please no messages on successful module load. Or at least
> not when statically built, but preferrably not at all.

By that logic should not the messages-on-load for netfilter be removed? ;-)

