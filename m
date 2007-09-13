From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Thu, 13 Sep 2007 15:13:06 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709131506040.31069@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl>
 <46E8B56E.7060705@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:33830 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419AbXIMONQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 10:13:16 -0400
In-Reply-To: <46E8B56E.7060705@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007, Jeff Garzik wrote:

> > Remove typedefs, volatiles and convert kmalloc()/memset() pairs to
> > kcalloc().  Also reformat the surrounding clutter.
> > 
> > Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> > ---
> 
> ACK, but patch does not apply cleanly to netdev-2.6.git#upstream (nor -mm)

 Hmm, works fine with linux-2.6.git#master.  I do not recall any recent 
activity with this driver -- I wonder what the difference is.  Let me 
see...

  Maciej
