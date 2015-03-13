From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 3/6] rhashtable: Move seed init into bucket_table_alloc
Date: Fri, 13 Mar 2015 11:03:00 +0100
Message-ID: <5502B5D4.5030003@iogearbox.net>
References: <20150313095607.GA598@gondor.apana.org.au> <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41567 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbCMKDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 06:03:07 -0400
In-Reply-To: <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2015 10:57 AM, Herbert Xu wrote:
> It seems that I have already made every rehash redo the random
> seed even though my commit message indicated otherwise :)
>
> Since we have already taken that step, this patch goes one step
> further and moves the seed initialisation into bucket_table_alloc.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

I wanted to suggest the same. :) Thanks!
