From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Mon, 12 May 2014 17:09:42 -0400
Message-ID: <CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
	<CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
	<CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33654 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758422AbaELVJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:09:44 -0400
Received: by mail-la0-f54.google.com with SMTP id pv20so2448903lab.27
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 14:09:42 -0700 (PDT)
In-Reply-To: <CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 3:58 PM, Lorenzo Colitti <lorenzo@google.com> wrote:

> I'm not sure what you mean by VRF implementation, do you have a
> pointer to the code?
>
>> (which afaik is done using network namespaces)?

See http://lists.openvz.org/pipermail/devel/2008-October/015055.html

I'm not sure what the current status of the patch is ( perhaps someone on
this list can comment? I thought this had been merged into kernel.git
at some point, but evidently not so?)  but after
http://lwn.net/Articles/407495/, a single
process should be able to open sockes in different namespaces.

> Socket marking is a per-socket operation, and a given process may have
> many sockets with many different marks. I don't think it's possible to
> do this using namespaces, because AFAIK a process can only be in one
> namespace.
