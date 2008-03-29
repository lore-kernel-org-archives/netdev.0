From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Fri, 28 Mar 2008 21:14:23 -0400
Message-ID: <47ED97EF.9070601@redhat.com>
References: <47E946C8.6020006@redhat.com>	<20080325235536.GB30298@gondor.apana.org.au>	<47EAB667.6010308@redhat.com> <20080327.164935.45964955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755758AbYC2BOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:14:30 -0400
In-Reply-To: <20080327.164935.45964955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Wed, 26 Mar 2008 16:47:35 -0400
> 
>> I think that it is inconvenient for caller functions to need
>> updateing truesize by themselves.
> 
> Most cases what I can see are in spots where skb->truesize
> cannot be modified because the SKB is possibly charged
> to a socket.
> 
> In these limited situations where skb->truesize adjustments
> really are needed, and legal, it is no harm to open code
> things.

Thank you for the comments.

I understood that updating truesize by caller wasn't problem.
And, I may misunderstand the spots where truesize can't be changed.

Then, I make patch to update truesize for each network subsystem and
ask a review of the patch. 

Best regards,
Hideo

--
Hitachi Computer Products (America) Inc.
