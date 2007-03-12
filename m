From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 04/18][SK_BUFF]: Introduce skb_reset_network_header(skb)
Date: Mon, 12 Mar 2007 07:14:08 -0300
Message-ID: <39e6f6c70703120314m1907f4d5sa33522efb14d220c@mail.gmail.com>
References: <39e6f6c70703112126g6aff108cgc05b490ba39ded73@mail.gmail.com>
	 <20070312082312.GB14831@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Netdev List" <netdev@vger.kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:28088 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965452AbXCLKOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 06:14:09 -0400
Received: by an-out-0708.google.com with SMTP id b33so1370967ana
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 03:14:08 -0700 (PDT)
In-Reply-To: <20070312082312.GB14831@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/12/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Mar 12, 2007 at 01:26:52AM -0300, Arnaldo Carvalho de Melo wrote:
> > For the common, open coded 'skb->nh.raw = skb->data' operation, so that we
> > can
> > later turn skb->nh.raw into a offset, reducing the size of struct sk_buff in
> > 64bit land while possibly keeping it as a pointer on 32bit.
> >
> > This one touches just the most simple case, next will handle the slightly
> > more
> > "complex" cases.
>
> I don't like the naming.  Either it should skb_reset_nh to match the field
> name (with a good kdoc comment explaning what nh means), or the field
> name should be network_header aswell.  In general I'd prefer the shorter
> names.

The fields will be renamed down the line, when their life as a union
of pointers will end, becoming just offsets.

> But besides the naming issue this looks like a very nice way to go down.

:-)

- Arnaldo
