From: Ilya Matveychikov <matvejchikov@gmail.com>
Subject: Re: A couple of questions about the SKB fragments
Date: Sat, 7 May 2016 12:21:01 +0300
Message-ID: <CAKh5naYgXko0NBefiNXio7_oPQmmuEtSw4BXCZFMmjshFriYMA@mail.gmail.com>
References: <CAKh5naYrZtf5y_Qw93G+GbxRVucsk4nbuiaguHcghtKEL=yQBw@mail.gmail.com>
 <572B2AEE.1020802@solarflare.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Aleksey.Baulin@gmail.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:36277 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbcEGJVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 05:21:21 -0400
Received: by mail-ob0-f196.google.com with SMTP id ds10so7902146obb.3
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 02:21:21 -0700 (PDT)
In-Reply-To: <572B2AEE.1020802@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-05-05 14:13 GMT+03:00 Edward Cree <ecree@solarflare.com>:
> On 05/05/16 08:40, Ilya Matveychikov wrote:
> > Is there any docs except the kernel sources itself to refer to?

> davem has some docs up at http://vger.kernel.org/~davem/skb.html and
> http://vger.kernel.org/~davem/skb_data.html
> In particular note the following:
> "The frag_list is used to maintain a chain of SKBs organized for
>  fragmentation purposes, it is _not_ used for maintaining paged data."
> So my reading would suggest there is no way to multiple-layer-fragment
> an SKB; the frags are page pointers and offsets, not entire sk_buff
> structs in their own right.
>

Seems that the docs is slightly outdated. I think the structure of SKB does
not impose any restrictions on the nesting of the fragments. But is there
any of them in the kernel's code?
