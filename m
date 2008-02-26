From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 26 Feb 2008 13:18:57 +0000
Message-ID: <20080226131857.GB16049@ff.dom.local>
References: <20080225215837.GA3281@ami.dom.local> <47C402A2.8040401@katalix.com> <20080226130334.GA16049@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:24801 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbYBZNRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 08:17:55 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1249950ugc.16
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 05:17:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080226130334.GA16049@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 01:03:34PM +0000, Jarek Poplawski wrote:
> On Tue, Feb 26, 2008 at 12:14:26PM +0000, James Chapman wrote:
...
> > there are hanging. Btw, they don't hang if I disable irqs around the  
> > ppp_input() call.
> 
> ...and disabling bh instead isn't enough, BTW?

I guess not: they are mostly disabled by ppp_input() itself...

So, it looks like a network card could mess here?

Jarek P.
