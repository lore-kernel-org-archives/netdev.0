From: psr <pradeep.rautela@gmail.com>
Subject: Re: [KJ] [KJ PATCH] Replacing alloc_pages(gfp, 0) with alloc_page(gfp) in net/core/pktgen.c
Date: Wed, 13 Jun 2007 19:58:31 +0530
Message-ID: <a901b49a0706130728q1d8f95a5h1d9a7c66a966e3c2@mail.gmail.com>
References: <1181702562.2282.12.camel@shani-win>
	 <a901b49a0706130312mba8a686m455b5cbf774cc159@mail.gmail.com>
	 <Pine.LNX.4.64.0706130912080.4392@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Shani Moideen" <shani.moideen@wipro.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com,
	kernel-janitors@lists.osdl.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:51821 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446AbXFMO2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 10:28:32 -0400
Received: by wa-out-1112.google.com with SMTP id v27so257601wah
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 07:28:31 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0706130912080.4392@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/13/07, Robert P. J. Day <rpjday@mindspring.com> wrote:
[snip]
> >
> > Does this makes any difference anyway? Both are same eventually?
> > What is the rational behind this? Can you please help me
> > understanding this?
>
> since this is one of the TO DO items i added to the list of things at
> the wiki:
>
> http://fsdev.net/wiki/index.php?title=Memory_allocation_cleanup
>
> i'll just toss in my $0.02.  if a short (more convenient) form of a
> routine has been defined, it should be used.  if you have no plans to
> use it, it shouldn't have been defined in the first place.

Oh... agreed

Thanks
--pradeep
>
> in short, make a consistent decision and go with it.
>
> rday
> --
> ========================================================================
> Robert P. J. Day
> Linux Consulting, Training and Annoying Kernel Pedantry
> Waterloo, Ontario, CANADA
>
> http://fsdev.net/wiki/index.php?title=Main_Page
> ========================================================================
>
