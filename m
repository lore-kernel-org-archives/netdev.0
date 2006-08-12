From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] CONFIG_PM=n slim: drivers/net/*
Date: Sat, 12 Aug 2006 11:39:25 -0700
Message-ID: <20060812113925.1acfaf36.akpm@osdl.org>
References: <20060812004623.GM6847@martell.zuzino.mipt.ru>
	<20060811184943.96419537.akpm@osdl.org>
	<20060812023014.GP6847@martell.zuzino.mipt.ru>
	<20060811194952.9d664698.akpm@osdl.org>
	<adar6zlnasq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11413 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030248AbWHLSjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 14:39:36 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adar6zlnasq.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Aug 2006 10:06:29 -0700
Roland Dreier <rdreier@cisco.com> wrote:

>  > > Also this won't allow
>  > > 
>  > > 	struct pci_driver {
>  > > 		...
>  > > 	#ifdef CONFIG_PM
>  > > 		int (*suspend)(...);
>  > > 		int (*resume)(...);
>  > > 	#endif
>  > > 		...
>  > > 	};
>  > > 
>  > > which is good for a) space savings in CONFIG_PM=n case, and
>  > > b) making drivers care about CONFIG_PM=n users hard way aka compilation
>  > > failure.
>  > 
>  > eh?  Both versions will generate identical code.
> 
> I think his point was that by #ifdef-ing out the assignment to
> .suspend/.resume, then the actual suspend/resume members of struct
> pci_driver could be removed in the CONFIG_PM=n case -- which would
> shrink sizeof (struct pci_driver).
> 

OIC.  Yes, that would be useful.
