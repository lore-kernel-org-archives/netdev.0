From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Mon, 16 Mar 2009 15:42:49 +0100
Message-ID: <49BE6569.4060801@trash.net>
References: <20090310151357.GA10658@ioremap.net> <49B78A4D.4060703@netfilter.org> <20090311100038.GA9560@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47027 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756729AbZCPOmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 10:42:52 -0400
In-Reply-To: <20090311100038.GA9560@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi Pablo.
> 
> On Wed, Mar 11, 2009 at 10:54:21AM +0100, Pablo Neira Ayuso (pablo@netfilter.org) wrote:
>>> Fingerprint matching rules can be downloaded from OpenBSD source tree
>>> and loaded via netlink connector into the kernel via special util found
>>> in archive. It will also listen for events about matching packets.
>> I like this feature. We have nfnetlink so I don't see why we should use
>> the netlink connector instead.

I fully agree.

> OSF exists about 6 years already, netlink configuration was added in
> 2005, I do not remember if nfnetlink existed those days (IIRC it did
> not, since I reused ULOG netlink first), right now I just cleanup
> what was written before.

We do have nfnetlink today however, so this argument does no longer
apply. I don't mind the order in which things are fixed up of course,
but before merging, it needs to be converted to nfnetlink.
