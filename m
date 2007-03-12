From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/18][SK_BUFF]: Introduce skb_reset_network_header(skb)
Date: Mon, 12 Mar 2007 08:23:12 +0000
Message-ID: <20070312082312.GB14831@infradead.org>
References: <39e6f6c70703112126g6aff108cgc05b490ba39ded73@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Netdev List <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40391 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965320AbXCLIXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 04:23:17 -0400
Content-Disposition: inline
In-Reply-To: <39e6f6c70703112126g6aff108cgc05b490ba39ded73@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 01:26:52AM -0300, Arnaldo Carvalho de Melo wrote:
> For the common, open coded 'skb->nh.raw = skb->data' operation, so that we 
> can
> later turn skb->nh.raw into a offset, reducing the size of struct sk_buff in
> 64bit land while possibly keeping it as a pointer on 32bit.
> 
> This one touches just the most simple case, next will handle the slightly 
> more
> "complex" cases.

I don't like the naming.  Either it should skb_reset_nh to match the field
name (with a good kdoc comment explaning what nh means), or the field
name should be network_header aswell.  In general I'd prefer the shorter
names.

But besides the naming issue this looks like a very nice way to go down.
