From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC
Date: Mon, 20 Nov 2006 15:35:48 -0800
Message-ID: <20061120153548.71f90b7a@freekitty>
References: <F09F8223E8BE7D42BDA1800B19F3440D922017@ALA-MAIL03.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47257 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030528AbWKTXfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 18:35:51 -0500
To: "Yang, Steve" <steve.yang@windriver.com>
In-Reply-To: <F09F8223E8BE7D42BDA1800B19F3440D922017@ALA-MAIL03.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 13:40:01 -0800
"Yang, Steve" <steve.yang@windriver.com> wrote:

> Stephen,
> 
> Sorry for responding late. 
> 
> 1. I've submitted two patches, one for NAPI and the other for SKB_Cache.
> They can go in individually. You've expressed objections to SKB_Cache.
> What about the one for NAPI?


Yes, the NAPI one is great.

> 
> 2. As for SKB_Cache patch, your concern about "maintenance" is valid.
> However, the cost for allocating skb is not trivial for performance,
> hence the patch. This is backed up by performance data measured. 20%
> difference is a conservative number here.
> 


I am not the final decider on this. Ask Jeff/David? Maybe there is some
more general work that can be done to speed up skb allocation.

-- 
Stephen Hemminger <shemminger@osdl.org>
