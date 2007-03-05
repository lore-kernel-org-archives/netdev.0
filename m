From: Jim Chow <jchow@vmware.com>
Subject: Re: [PATCH/RFC] Use of uninitialized data in udp_recvmsg().
Date: Mon, 5 Mar 2007 15:25:10 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703051504270.11127@jchow-amax.eng.vmware.com>
References: <E1HOLBe-000660-00@gondolin.me.apana.org.au>
 <Pine.LNX.4.64.0703051257520.27979@jchow-amax.eng.vmware.com>
 <20070305233449.GA24159@gondor.apana.org.au> <20070305235732.GA24642@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:33724 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932809AbXCFA2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 19:28:42 -0500
In-Reply-To: <20070305235732.GA24642@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Herbert Xu wrote:
> It's just too error-prone to rely on it to not have MSG_TRUNC set.

Agreed.

> I'm going to clean this up for UDP and improve the UDP-lite checksum
> handling while I'm at it.

Great.  It'll be good to get this years-old UDP bug fixed.

Thanks,
Jim
