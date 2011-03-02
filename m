From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 02/27] HFI: Add HFI adapter control structure
Date: Wed, 02 Mar 2011 22:44:30 +0000
Message-ID: <1299105870.4277.37.camel@localhost>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	 <1299100213-8770-2-git-send-email-dykmanj@linux.vnet.ibm.com>
	 <20110302142126.193a8817@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dykmanj@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8510 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab1CBWof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:44:35 -0500
In-Reply-To: <20110302142126.193a8817@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 14:21 -0800, Stephen Hemminger wrote:
> On Wed,  2 Mar 2011 16:09:48 -0500
> dykmanj@linux.vnet.ibm.com wrote:
> 
> > diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
> > index 80790c6..6fe4e60 100644
> > --- a/drivers/net/hfi/core/Makefile
> > +++ b/drivers/net/hfi/core/Makefile
> > @@ -1,5 +1,6 @@
> >  #
> >  # Makefile for the HFI device driver for IBM eServer System p
> >  #
> > -hfi_core-objs:=	hfidd_init.o
> > +hfi_core-objs:=	hfidd_adpt.o \
> > +		hfidd_init.o
> >  obj-$(CONFIG_HFI) += hfi_core.o
> > diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
> > new file mode 100644
> > index 0000000..d64fa38
> > --- /dev/null
> > +++ b/drivers/net/hfi/core/hfidd_adpt.c
[...]
> > +void hfidd_free_adapter(struct hfidd_acs *p_acs)
> > +{
> > +	kfree(p_acs);
> > +	p_acs = NULL;
> > +	return;
> > +}
> 
> If these were not in a separate file the could be marked as static.

I assume they're intending to add some more interesting code here in the
next installment.

> Doing a return; on last line of a void function is considered poor
> style since it is unnecessary.

Assigning to a local variable just before returning is also silly.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

