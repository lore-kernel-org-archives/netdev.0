From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: drop reference to unused option
 embedded from manpage
Date: Tue, 24 Mar 2015 14:55:24 -0700
Message-ID: <20150324145524.491e6435@urahara>
References: <1426606450-30133-1-git-send-email-gospo@cumulusnetworks.com>
	<5508CC3B.3040306@lab.ntt.co.jp>
	<20150319161419.GA20295@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36242 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbCXVzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:55:22 -0400
Received: by padcy3 with SMTP id cy3so6289425pad.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 14:55:22 -0700 (PDT)
In-Reply-To: <20150319161419.GA20295@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Mar 2015 12:14:22 -0400
Andy Gospodarek <gospo@cumulusnetworks.com> wrote:

> On Wed, Mar 18, 2015 at 09:52:11AM +0900, Toshiaki Makita wrote:
> > On 2015/03/18 0:34, Andy Gospodarek wrote:
> > > While looking at the manpage, I noticed a reference to 'embedded' that was
> > > added by this commit:
> > > 
> > > 	commit d611682a8c8f28205158e6d3a7d5e2d01db022cc
> > > 	Author: John Fastabend <john.r.fastabend@intel.com>
> > > 	Date:   Thu Sep 13 23:50:36 2012 -0700
> > > 
> > > 	    iproute2: bridge: finish removing replace option in man pages
> > > 
> > > I no longer see any reference to the 'embedded' option in any c- or h-files, so
> > > it seems worthwhile to remove.
> > 
> > Actually, in addition, "master" option is missing.
> > Also, the current explanation of "self" looks incorrect and appropriate
> > for "master".
> > 
> > I wondered if you could fix them together with this... or I will do later.
> > 
> 
> Good idea, but I would prefer the suggested change as another patch.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I applied this patch, feel free to do more cleanups in later patches.
