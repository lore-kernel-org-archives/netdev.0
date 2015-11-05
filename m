From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] decnet: remove macro-local declarations
Date: Thu, 5 Nov 2015 21:08:17 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1511052107501.2065@localhost6.localdomain6>
References: <1446718696-32505-1-git-send-email-Julia.Lawall@lip6.fr> <20151105.142619.983467860147585345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105.142619.983467860147585345.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Nov 2015, David Miller wrote:

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> Date: Thu,  5 Nov 2015 11:18:16 +0100
> 
> > Move the variable declarations from the for_nexthops macro to the
> > surrounding context, so that it is clear where these variables are
> > declared.  This also makes it possible to remove the endfor_nexthops macro.
> > 
> > This change adds new arguments to the macro for_nexthops.  They are ordered
> > such that a pointer to the referenced object comes first, the index in the
> > list comes next, and the list itself comes last, roughly in analogy with
> > the list_for_each macros.
> > 
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> > 
> > ---
> > 
> > This patch takes care of a single file, where the macros are defined
> > locally.  If the basic transformation looks OK, I will change the other
> > files that either likewise define their own macros or use the macros in
> > net/mpls/internal.h.  The potentially affected files are:
>  ...
> 
> This looks fine to me.

Would it be preferable to remove the macro entirely and inline the for 
loop header?

julia

> Please resubmit this when net-next opens back up, which should be
> shortly after -rc1.
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
