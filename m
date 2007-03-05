From: Jim Chow <jchow@vmware.com>
Subject: Re: [PATCH/RFC] Use of uninitialized data in udp_recvmsg().
Date: Mon, 5 Mar 2007 13:01:16 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703051257520.27979@jchow-amax.eng.vmware.com>
References: <E1HOLBe-000660-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:60744 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751000AbXCEWDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 17:03:43 -0500
In-Reply-To: <E1HOLBe-000660-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Herbert Xu wrote:
> msg_flags [...] its initial value is not used.

That's not true.  Please see my post.

Specifically, at linux-2.6.20.1/net/ipv4/udp.c:843, it seems that 
udp_recvmsg() can randomly ignore whether the HW has computed a checksum 
and compute it in SW redundantly.

Jim
