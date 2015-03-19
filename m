From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] bridge: drop reference to unused option
 embedded from manpage
Date: Thu, 19 Mar 2015 12:14:22 -0400
Message-ID: <20150319161419.GA20295@gospo.home.greyhouse.net>
References: <1426606450-30133-1-git-send-email-gospo@cumulusnetworks.com>
 <5508CC3B.3040306@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34488 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbbCSQOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:14:30 -0400
Received: by qcaz10 with SMTP id z10so70590663qca.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 09:14:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5508CC3B.3040306@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2015 at 09:52:11AM +0900, Toshiaki Makita wrote:
> On 2015/03/18 0:34, Andy Gospodarek wrote:
> > While looking at the manpage, I noticed a reference to 'embedded' that was
> > added by this commit:
> > 
> > 	commit d611682a8c8f28205158e6d3a7d5e2d01db022cc
> > 	Author: John Fastabend <john.r.fastabend@intel.com>
> > 	Date:   Thu Sep 13 23:50:36 2012 -0700
> > 
> > 	    iproute2: bridge: finish removing replace option in man pages
> > 
> > I no longer see any reference to the 'embedded' option in any c- or h-files, so
> > it seems worthwhile to remove.
> 
> Actually, in addition, "master" option is missing.
> Also, the current explanation of "self" looks incorrect and appropriate
> for "master".
> 
> I wondered if you could fix them together with this... or I will do later.
> 

Good idea, but I would prefer the suggested change as another patch.
