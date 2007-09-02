From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.23-rc4-mm1: unpingable box and NULL dereference at tcp_rto_min()
Date: Mon, 3 Sep 2007 01:19:07 +0400
Message-ID: <20070902211907.GA2452@martell.zuzino.mipt.ru>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070902023618.GA2537@martell.zuzino.mipt.ru> <20070902135245.aed7c7a9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:11946 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbXIBVTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 17:19:14 -0400
Received: by mu-out-0910.google.com with SMTP id i10so1750349mue
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2007 14:19:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070902135245.aed7c7a9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 02, 2007 at 01:52:45PM -0700, Andrew Morton wrote:
> > On Sun, 2 Sep 2007 06:36:19 +0400 Alexey Dobriyan <adobriyan@gmail.com> wrote:
> > The bad news is something knocked off box from the net, then panicked it:
> 
> Yeah, the net tree has been quite bad lately.  Unusually bad - it's usually
> one of the good ones.
> 
> It also breaks a lot of the net driver work in several other trees (I dropped
> git-ixgbe.patch wholesale because of this).  But there isn't a lot we can
> do about that.  

OK, I'm currently running with "dst entry can be NULL" fix from net
tree, so far it's fine.
