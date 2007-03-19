From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/1] [SK_BUFF]: Adjust the zeroing up to tail in __alloc_skb too
Date: Mon, 19 Mar 2007 17:48:02 -0300
Message-ID: <39e6f6c70703191348w6ab21c32nefd9a0fdfcc90917@mail.gmail.com>
References: <20070319135030.GE17811@ghostprotocols.net>
	 <20070319.121622.55507267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:29953 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbXCSUsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 16:48:30 -0400
Received: by an-out-0708.google.com with SMTP id b33so1532288ana
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 13:48:29 -0700 (PDT)
In-Reply-To: <20070319.121622.55507267.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/19/07, David Miller <davem@davemloft.net> wrote:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Mon, 19 Mar 2007 10:50:30 -0300
>
> > Hi David,
> >
> >       Please pull from:
> >
> > master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22
>
> Pulled, thanks Arnaldo.
>
> Can you please verify the white-space in your patches in the future?
> I have a ton of whitespace warnings from GIT to fix up as I'm rebasing
> the net-2.6.22 tree.  The following "pcheck" script (which I've
> probably posted like 10 or more times) works great for this.
>
> Unfortunately, when you "git commit" stuff GIT doesn't do whitespace
> damange checking by default, only when you are importing patches or
> similar :-/
>
> #!/bin/sh
> set -x
> git apply --check --whitespace=error-all $1

OK, I wasn' t expecting any whitspaces, probably were whitespaces
already there that were kept, I'll try and check future patches.

- Arnaldo
