From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: hip04: Omit private ndo_get_stats function
Date: Wed, 15 Feb 2017 02:51:21 -0800
Message-ID: <1487155881.6214.54.camel@perches.com>
References: <20170214141006.11510-1-tklauser@distanz.ch>
         <1487154488.6214.53.camel@perches.com> <20170215103858.GA27277@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0148.hostedemail.com ([216.40.44.148]:56158 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751789AbdBOKvY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 05:51:24 -0500
In-Reply-To: <20170215103858.GA27277@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 11:38 +0100, Tobias Klauser wrote:
> On 2017-02-15 at 11:28:08 +0100, Joe Perches <joe@perches.com> wrote:
> > On Tue, 2017-02-14 at 15:10 +0100, Tobias Klauser wrote:
> > > hip04_get_stats() just returns dev->stats so we can leave it
> > > out altogether and let dev_get_stats() do the job.
> > 
> > This could be done for at least a few more drivers:
> > 
> > drivers/net/ethernet/chelsio/cxgb/sge.c
> 
> I don't see an .ndo_get_stats being defined/set in this file. AFAICT,
> this driver sets .ndo_get_stats to t1_get_stats(), which does some
> additional extraction of statistics from device registers and thus
> shouldn't be removed.

Right.

> > drivers/net/ethernet/intel/e1000/e1000_main.c
> > drivers/net/ethernet/intel/ixgb/ixgb_main.c
> 
> Will cover these in follow-up patches, thanks.

Thanks.

> > drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> 
> A patch for pch_gbe already landed in net-next.

Great, cheers, Joe
