From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] xfrm: fix the xfrm_policy/state_walk
Date: Wed, 22 Apr 2015 16:06:41 +0800
Message-ID: <CAJFZqHySg10XBHVAavVipheo+1zrFYH=qCtDg-PyM596d=mZCg@mail.gmail.com>
References: <1429689214-10827-1-git-send-email-roy.qing.li@gmail.com>
	<20150422075755.GA9163@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:34504 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbbDVIGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 04:06:42 -0400
Received: by qcyk17 with SMTP id k17so89095498qcy.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 01:06:42 -0700 (PDT)
In-Reply-To: <20150422075755.GA9163@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 3:57 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>
> This is not a bug fix but an optimisation.  The walker entries are
> all marked as dead and will be skipped by the loop.
>
> However, I don't see anything wrong with this optimisation.
>
> Cheers,


thanks, you are right, I will rewrite the commit header

-Roy
