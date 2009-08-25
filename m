From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 12:03:58 -0700
Message-ID: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
References: <alpine.DEB.1.10.0908250946520.5972@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, niv@linux.vnet.ibm.com,
	sri@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42651 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627AbZHYTEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 15:04:11 -0400
In-Reply-To: <alpine.DEB.1.10.0908250946520.5972@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter <cl@linux-foundation.org> wrote on 08/25/2009 06:48:24 
AM:

> On Mon, 24 Aug 2009, Sridhar Samudrala wrote:

> > If we count these drops as qdisc drops, should we also count them as 
IP OUTDISCARDS?
> 
> Yes.

Actually, no. (!)

IP_OUTDISCARDS should count the packets IP dropped, not
anything dropped at a lower layer (which, in general, it
is not aware of). If you count these in multiple layers,
then you don't really know who dropped it.

                                                +-DLS

