From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwl4965: Enable checking of format strings
Date: Tue, 28 Apr 2015 19:49:31 +0200
Message-ID: <20150428174929.GA8397@redhat.com>
References: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
 <877fsw5iq1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <877fsw5iq1.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 28, 2015 at 07:19:02PM +0300, Kalle Valo wrote:
> Rasmus Villemoes <linux@rasmusvillemoes.dk> writes:
> 
> > Since these fmt_* variables are just const char*, and not const
> > char[], gcc (and smatch) doesn't to type checking of the arguments to
> > the printf functions. Since the linker knows perfectly well to merge
> > identical string constants, there's no point in having three static
> > pointers waste memory and give an extra level of indirection.
> >
> > This removes over 100 "non-constant format argument" warnings from
> > smatch, accounting for about 20% of all such warnings in an
> > allmodconfig.
> >
> > Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> 
> So what's the conclusion, should I commit this patch or not?
> 
> Full discussion here:
> 
> https://patchwork.kernel.org/patch/5814811/

I do not see the point of the patch. If compiler behave not
optimally, fix the compiler. NACK.

Stanislaw
