From: James Morris <jmorris@redhat.com>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Tue, 27 Jul 2004 14:57:04 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407271456220.7908-100000@dhcp83-76.boston.redhat.com>
References: <200407272150.50664.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Mackall <mpm@selenic.com>, Niranjan <niranjan_cs2905@yahoo.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407272150.50664.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004, Vladimir Kondratiev wrote:

> > The crypto functions should be safe to use in softirq context.
> It should be, but:
> <crypto/api.c:121>
> struct crypto_tfm *crypto_alloc_tfm(const char *name, u32 flags)
> {
>         struct crypto_tfm *tfm = NULL;
>         struct crypto_alg *alg;
> 
>         alg = crypto_alg_mod_lookup(name);
>         if (alg == NULL)
>                 goto out;
> 
>         tfm = kmalloc(sizeof(*tfm) + alg->cra_ctxsize, GFP_KERNEL);
> 

By crypto functions I meant encrypt() decrypt() etc, not the allocation.


- James
-- 
James Morris
<jmorris@redhat.com>
