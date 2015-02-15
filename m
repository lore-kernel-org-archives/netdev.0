From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: vnet problem (bug? feature?)
Date: Sun, 15 Feb 2015 16:16:21 -0500
Message-ID: <CACP96tRBPy4cakmJY_K9zrYbgWLgNfxDo4inrH8qV6pgRtR-1g@mail.gmail.com>
References: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de>
	<CAHA+R7NUojPsLY9LOC94S0uussbwKsGRdcbazNmGGLbXvxCk-A@mail.gmail.com>
	<20150214101547.GA9335@faui40p.informatik.uni-erlangen.de>
	<20150214131744.051b90fc8dfdbf4e1bfe6bfb@mindspring.com>
	<20150215190008.GA25792@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bill Fink <billfink@mindspring.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
To: Toerless Eckert <tte@cs.fau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:65359 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244AbbBOVQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 16:16:23 -0500
Received: by mail-we0-f172.google.com with SMTP id k48so25898119wev.3
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 13:16:22 -0800 (PST)
In-Reply-To: <20150215190008.GA25792@faui40p.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2015 at 2:00 PM, Toerless Eckert <tte@cs.fau.de> wrote:
> *Bingo* rp_filter did the trick.
>
> nstat is fairly useless to figrue this out, no RPF counters.
>
> Quite strange to see rp_filter. Especilly for multicast. But i haven't
> followed linux for many years in this level of detail. I thought
> Linux was always weak host model. But even for strong host model,
> i can't remember that RPF checking was done in the past (for hosts,
> not routers obviously).

RPF !=  strong/weak ES models defined in Section 3.3.4.2 of rfc1122.

RPF is about ingress filtering (rfc 3704) and verifying that the return
path to the src addr of the packet would go out on the same interface
it came on. The wiki page on Reverse_path_forwarding has some detail.
--Sowmini
