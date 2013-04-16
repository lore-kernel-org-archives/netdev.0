From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 23:25:31 +0200
Message-ID: <20130416212531.GA19634@electric-eye.fr.zoreil.com>
References: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
 <516D60E0.6000107@cogentembedded.com>
 <CAOMZO5CGn=aetDoo-oc3Ub3ZL=8RKsPzH6jkXvifykSnWrV_Rg@mail.gmail.com>
 <516D8649.4030604@cogentembedded.com>
 <1366134545.28609.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Fabio Estevam <festevam@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50335 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965262Ab3DPVZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:25:51 -0400
Content-Disposition: inline
In-Reply-To: <1366134545.28609.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> :
> On Tue, 2013-04-16 at 21:11 +0400, Sergei Shtylyov wrote:
> > On 16-04-2013 19:22, Fabio Estevam wrote:
> > >>> +static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
> > >>> +#define FEC_PM_OPS (&fec_pm_ops)
> > >>     Nit: parens are useless here.
> 
> Is this macro indirection even useful?

When CONFIG_PM_SLEEP is not set, it saves a few bytes setting the pm
reference to NULL instead of referencing a zero filled struct.

-- 
Ueimor
