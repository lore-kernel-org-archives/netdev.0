From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 4.10 0/6] Switch BPF's digest to SHA256
Date: Mon, 26 Dec 2016 16:20:58 +0800
Message-ID: <20161226082058.GA9013@gondor.apana.org.au>
References: <cover.1482545792.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
        Jason@zx2c4.com, hannes@stressinduktion.org,
        alexei.starovoitov@gmail.com, edumazet@google.com,
        ebiggers3@gmail.com, tom@herbertland.com, davem@davemloft.net,
        luto@kernel.org
To: Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:55873 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751537AbcLZIVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 03:21:15 -0500
Content-Disposition: inline
In-Reply-To: <cover.1482545792.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@kernel.org> wrote:
> Since there are plenty of uses for the new-in-4.10 BPF digest feature
> that would be problematic if malicious users could produce collisions,
> the BPF digest should be collision-resistant.  SHA-1 is no longer
> considered collision-resistant, so switch it to SHA-256.
> 
> The actual switchover is trivial.  Most of this series consists of
> cleanups to the SHA256 code to make it usable as a standalone library
> (since BPF should not depend on crypto).
> 
> The cleaned up library is much more user-friendly than the SHA-1 code,
> so this also significantly tidies up the BPF digest code.
> 
> This is intended for 4.10.  If this series misses 4.10 and nothing
> takes its place, then we'll have an unpleasant ABI stability
> situation.

Can you please explain why BPF needs to be able to use SHA directly
rather than through the crypto API?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
