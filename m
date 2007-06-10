From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCH 1/1] make network DMA usable for non-tcp drivers
Date: Sun, 10 Jun 2007 09:49:05 -0700
Message-ID: <e9c3a7c20706100949g68689ac0k8186408fdd6d4efa@mail.gmail.com>
References: <20070605102427.26dd7fac.randy.dunlap@oracle.com>
	 <20070608143053.GC10489@coraid.com>
	 <20070608120716.1e059cf3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ed L. Cashin" <ecashin@coraid.com>, netdev@vger.kernel.org,
	s.a.hopkins@gmail.com, jgarzik@pobox.com, randy.dunlap@oracle.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:24430 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757005AbXFJQtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 12:49:05 -0400
Received: by an-out-0708.google.com with SMTP id d31so334701and
        for <netdev@vger.kernel.org>; Sun, 10 Jun 2007 09:49:05 -0700 (PDT)
In-Reply-To: <20070608120716.1e059cf3.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > @@ -130,3 +130,5 @@ end:
> >  fault:
> >       return -EFAULT;
> >  }
> > +
> > +EXPORT_SYMBOL(dma_skb_copy_datagram_iovec);
>
> We wouldn't want to merge this until code which actually uses the export is
> also merged.
>

...and I recommend EXPORT_SYMBOL_GPL following the lead of the other
async dma options in -mm.
