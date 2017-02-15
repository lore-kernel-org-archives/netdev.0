From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: hip04: Omit private ndo_get_stats function
Date: Wed, 15 Feb 2017 11:38:58 +0100
Message-ID: <20170215103858.GA27277@distanz.ch>
References: <20170214141006.11510-1-tklauser@distanz.ch>
 <1487154488.6214.53.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:34103 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751532AbdBOKjC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 05:39:02 -0500
Content-Disposition: inline
In-Reply-To: <1487154488.6214.53.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-02-15 at 11:28:08 +0100, Joe Perches <joe@perches.com> wrote:
> On Tue, 2017-02-14 at 15:10 +0100, Tobias Klauser wrote:
> > hip04_get_stats() just returns dev->stats so we can leave it
> > out altogether and let dev_get_stats() do the job.
> 
> This could be done for at least a few more drivers:
> 
> drivers/net/ethernet/chelsio/cxgb/sge.c

I don't see an .ndo_get_stats being defined/set in this file. AFAICT,
this driver sets .ndo_get_stats to t1_get_stats(), which does some
additional extraction of statistics from device registers and thus
shouldn't be removed.

> drivers/net/ethernet/intel/e1000/e1000_main.c
> drivers/net/ethernet/intel/ixgb/ixgb_main.c

Will cover these in follow-up patches, thanks.

> drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c

A patch for pch_gbe already landed in net-next.
