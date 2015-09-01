From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: support global vtag assochash and per endpoint
 s(d)port assochash table
Date: Wed, 2 Sep 2015 04:11:44 +0800
Message-ID: <CADvbK_cLgw3xnnT2_ENZgaFTWncpoKNF2bazBWuX152ZSLUG4w@mail.gmail.com>
References: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
	<55E4E89A.8060508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	daniel@iogearbox.net, davem <davem@davemloft.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33984 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbIAULp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 16:11:45 -0400
Received: by oiev17 with SMTP id v17so6761382oie.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 13:11:45 -0700 (PDT)
In-Reply-To: <55E4E89A.8060508@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> In addition to what David said and looking at it from a different angle... 256 buckets
> may not be enough for someone with a single endpoint and alot of associations.  You
> will still hit a long chain on INIT and COOKIE-ECHO chunks.
>
> Switching to using rhashtable for association hash would be very nice.
>
good idea, I will think about it.

> Also, see if you can split this into 2 parts, one that does vtag hash and
> the other is refactoring.  It would make it much easier to review.
>
I tried, it's kind of hard, cause i do not add the vtag hashtable, but
change the
original hashtable to vtag hashtable, which make sendmsg lost its hashtable.
I have to add another one for per endpoint.
anyway, I will try to split it again, thanks.

> -vlad
>
