From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2.6.19 1/2] X.25: Adds call forwarding to X.25
Date: Thu, 4 Jan 2007 10:27:02 +0000
Message-ID: <20070104102702.30630a9d@localhost.localdomain>
References: <1167881822.5124.88.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, eis@baty.hanse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751114AbXADKQn@vger.kernel.org>
To: ahendry <ahendry@tusc.com.au>
In-Reply-To: <1167881822.5124.88.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	struct sk_buff *skbn;
> +	skbn = skb_clone(skb, GFP_ATOMIC);
> +

If this fails then you starting passing NULL around. I'm also a bit
confused as to where you free the copy in all the error cases ?

Is there any reason for creating skbn here rather than in
skb_forward_call ?
