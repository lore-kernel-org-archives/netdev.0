From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: Unnecessary check in __sk_stream_mem_reclaim?
Date: Wed, 12 Jul 2006 15:17:43 +1200
Message-ID: <5640c7e00607112017v326ebb4qcdd0a10a79df2de2@mail.gmail.com>
References: <5640c7e00607111942jc0ef6cdyc0466dc0cfd5a00b@mail.gmail.com>
	 <E1G0V93-00037K-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:21845 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751237AbWGLDRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 23:17:44 -0400
Received: by nf-out-f131.google.com with SMTP id k65so5906nfa
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 20:17:43 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <E1G0V93-00037K-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> >
> > It looks to me like this check here in net/core/stream.c for
> > __sk_stream_mem_reclaim:
> >        if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {
> >
> > is unnecessary.
>
> It's needed after skb's have been freed which can push sk_forward_alloc
> above a quantum.
>
I'm not saying the check is unneeded - just saying doing it twice is unneeded.

Sorry Herbert for two copies - forgot to add netdev first time.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
