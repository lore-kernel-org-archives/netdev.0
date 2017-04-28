From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable - Cap total number of entries to 2^31
Date: Fri, 28 Apr 2017 19:31:45 +0800
Message-ID: <20170428113145.GA7843@gondor.apana.org.au>
References: <20170427054451.GA529@gondor.apana.org.au>
 <0cd0286d-b81d-7bf4-d345-7ef098b9a998@broadcom.com>
 <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
 <acb22f3f-8286-01f2-e536-0ab44eb06b34@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, fw@strlen.de,
        netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <acb22f3f-8286-01f2-e536-0ab44eb06b34@de.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 12:23:15PM +0200, Christian Borntraeger wrote:
>
> I can reproduce this boot failure on s390 bisected to 
> commit 6d684e54690caef45cf14051ddeb7c71beeb681b
>    rhashtable: Cap total number of entries to 2^31
> in linux-next from Apr 28

It should go away with

https://patchwork.ozlabs.org/patch/756233/

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
