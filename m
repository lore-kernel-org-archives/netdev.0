From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 6 Dec 2007 00:15:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712052336240.9572@kivilampi-30.cs.helsinki.fi>
References: <20071205.053031.87154402.davem@davemloft.net>
 <1196873587.10819.30.camel@localhost> <20071205163338.50aff45d@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45892 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbXLEWPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 17:15:51 -0500
In-Reply-To: <20071205163338.50aff45d@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Dec 2007, Stephen Hemminger wrote:

> On Wed, 05 Dec 2007 08:53:07 -0800
> Joe Perches <joe@perches.com> wrote:
> 
> > > it occurred to me that we might want to do something
> > > like a state change event generator.
> > 
> > This could be a basis for an interesting TCP
> > performance tester.
> 
> That is what tcpprobe does but it isn't detailed enough to address SACK
> issues.

...It would be nice if that could be generalized so that the probe could 
be attached to some other functions than tcp_rcv_established instead.

If we convert remaining functions that don't have sk or tp as first 
argument so that sk is listed first (should be many with wrong ordering 
if any), then maybe a generic handler could be of type:

jtcp_entry(struct sock *sk, ...)

or when available:

jtcp_entry(struct sock *sk, struct sk_buff *ack, ...)


-- 
 i.
