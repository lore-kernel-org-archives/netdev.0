From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Thu, 27 Mar 2008 16:49:35 -0700 (PDT)
Message-ID: <20080327.164935.45964955.davem@davemloft.net>
References: <47E946C8.6020006@redhat.com>
	<20080325235536.GB30298@gondor.apana.org.au>
	<47EAB667.6010308@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54085
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752573AbYC0Xtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 19:49:35 -0400
In-Reply-To: <47EAB667.6010308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Wed, 26 Mar 2008 16:47:35 -0400

> I think that it is inconvenient for caller functions to need
> updateing truesize by themselves.

Most cases what I can see are in spots where skb->truesize
cannot be modified because the SKB is possibly charged
to a socket.

In these limited situations where skb->truesize adjustments
really are needed, and legal, it is no harm to open code
things.
