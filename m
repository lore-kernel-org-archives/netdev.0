From: Niranjan <niranjan_cs2905@yahoo.com>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Wed, 28 Jul 2004 08:55:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728155557.38198.qmail@web53006.mail.yahoo.com>
References: <Xine.LNX.4.44.0407271456220.7908-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, Niranjan <niranjan_cs2905@yahoo.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>, Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <Xine.LNX.4.44.0407271456220.7908-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I got the code working by including the encrypt() and
decrypt() function inside the WLAN driver. 
Is there any better way to get the CrytoAPI code
working from the driver or some other CryptoAPI
implementation ?

Warm Regards,
-Niranjan


--- James Morris <jmorris@redhat.com> wrote:

> On Tue, 27 Jul 2004, Vladimir Kondratiev wrote:
> 
> > > The crypto functions should be safe to use in
> softirq context.
> > It should be, but:
> > <crypto/api.c:121>
> > struct crypto_tfm *crypto_alloc_tfm(const char
> *name, u32 flags)
> > {
> >         struct crypto_tfm *tfm = NULL;
> >         struct crypto_alg *alg;
> > 
> >         alg = crypto_alg_mod_lookup(name);
> >         if (alg == NULL)
> >                 goto out;
> > 
> >         tfm = kmalloc(sizeof(*tfm) +
> alg->cra_ctxsize, GFP_KERNEL);
> > 
> 
> By crypto functions I meant encrypt() decrypt() etc,
> not the allocation.
> 
> 
> - James
> -- 
> James Morris
> <jmorris@redhat.com>
> 
> 
> 
> 



	
		
__________________________________
Do you Yahoo!?
New and Improved Yahoo! Mail - 100MB free storage!
http://promotions.yahoo.com/new_mail 
