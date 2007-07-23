From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Mon, 23 Jul 2007 10:58:22 +0100
Message-ID: <20070723105822.3a9fa152@oldman.hamilton.local>
References: <20070720.223129.59470764.davem@davemloft.net>
	<p73lkd9vqfr.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33193 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756334AbXGWJ6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 05:58:30 -0400
In-Reply-To: <p73lkd9vqfr.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21 Jul 2007 15:26:00 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> David Miller <davem@davemloft.net> writes:
> > 
> > Good candidates for taking advantage of multi-napi are:
> > 
> > 1) e1000
> > 2) ucc_geth
> > 3) ehea
> > 4) sunvnet
> 
> s2io.c

sky2.c could use it because of issues with dual-port that share
one napi for status.
