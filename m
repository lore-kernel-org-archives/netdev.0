From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 5/7] rhashtable: abstract out function to get
 hash
Date: Tue, 20 Sep 2016 19:58:03 +0200
Message-ID: <20160920175803.GE3291@pox.localdomain>
References: <1473895376-347096-6-git-send-email-tom@herbertland.com>
 <20160920093659.GA20975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        kernel-team@fb.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38658 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754694AbcITR6H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:58:07 -0400
Received: by mail-wm0-f51.google.com with SMTP id l132so48283294wmf.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 10:58:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160920093659.GA20975@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/16 at 05:36pm, Herbert Xu wrote:
> Tom Herbert <tom@herbertland.com> wrote:
> > Split out most of rht_key_hashfn which is calculating the hash into
> > its own function. This way the hash function can be called separately to
> > get the hash value.
> > 
> > Acked-by: Thomas Graf <tgraf@suug.ch>
> > Signed-off-by: Tom Herbert <tom@herbertland.com>
> 
> I don't get this one.  You're just using jhash, right? Why not
> call jhash directly instead of rht_get_key_hashfn?

FYI, there is a v2 of this series, just so you don't have to do the
work twice.

I understand this particular patch as an effort not to duplicate
hash function selection such as jhash vs jhash2 based on key_len.
