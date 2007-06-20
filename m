From: "Prafulla Deuskar" <pdeuskar01@gmail.com>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Wed, 20 Jun 2007 12:35:59 -0700
Message-ID: <7176eb5f0706201235w1bee20e0n8c25207176e61b0@mail.gmail.com>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
	 <20070619090027.3312f2cf@localhost.localdomain>
	 <4678472D.5050907@trash.net>
	 <20070619.154840.55744015.davem@davemloft.net>
	 <4678CA7F.8070002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:7424 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbXFTTgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 15:36:02 -0400
Received: by nf-out-0910.google.com with SMTP id g13so10321nfb
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 12:36:00 -0700 (PDT)
In-Reply-To: <4678CA7F.8070002@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/19/07, Jeff Garzik <jeff@garzik.org> wrote:
> David Miller wrote:
> > This is actually a real issue for virtualization, and many
> > if not all current generation ethernet chips support
> > programming several unicast ethernet addresses in the MAC.
> >
> > Networking switches in domain0 on virtualization hosts use
> > this feature to support seperate MACs per guest node,
> > and if the chip doesn't support this the chip is put into
> > promiscuous mode.
> >
> > We don't have any clean interfaces by which to do this MAC
> > programming, and we do need something for it soon.
>
>
> Yep, that's been on my long term wish list for a while, as well.
>
> Overall I would like to see a more flexible way of allowing the net
> stack to learn each NIC's RX filter capabilities, and exploiting them.
> Plenty of NICs, even 100Mbps ones, support RX filter management that
> allows scanning for $hw_limit unicast addresses, before having to put
> the hardware into promisc mode.
>
>        Jeff

So how do we manage mac address to RX queue association?
Ideally we should extend ethtool to do that rather than inventing a
new tool - Is that acceptable?

-Prafulla
