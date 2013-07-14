From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH] atl1e: fix dma mapping warnings
Date: Sat, 13 Jul 2013 22:22:36 -0400
Message-ID: <20130714022235.GA3429@neilslaptop.think-freely.org>
References: <1373641128-13634-1-git-send-email-nhorman@tuxdriver.com>
 <20130712.162652.1236723636413575644.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35180 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab3GNCXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 22:23:02 -0400
Content-Disposition: inline
In-Reply-To: <20130712.162652.1236723636413575644.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 04:26:52PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 12 Jul 2013 10:58:48 -0400
> 
> > Recently had this backtrace reported:
>  ...
> > The usual straighforward failure to check for dma_mapping_error after a map
> > operation is completed.
> > 
> > This patch should fix it, the reporter wandered off after filing this bz:
> > https://bugzilla.redhat.com/show_bug.cgi?id=954170
> > 
> > and I don't have hardware to test, but the fix is pretty straightforward, so I
> > figured I'd post it for review.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied with one style fix:
> 
> > -static void atl1e_tx_map(struct atl1e_adapter *adapter,
> > +static int atl1e_tx_map(struct atl1e_adapter *adapter,
> >  		      struct sk_buff *skb, struct atl1e_tpd_desc *tpd)
> 
> I properly reindented the second line of the argument list.
> 
Understood, thank you David.
Neil

> Thanks.
> 
