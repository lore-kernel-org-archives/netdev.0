From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 10:49:05 -0700
Message-ID: <1366134545.28609.1.camel@joe-AO722>
References: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
	 <516D60E0.6000107@cogentembedded.com>
	 <CAOMZO5CGn=aetDoo-oc3Ub3ZL=8RKsPzH6jkXvifykSnWrV_Rg@mail.gmail.com>
	 <516D8649.4030604@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42786 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965079Ab3DPRtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 13:49:05 -0400
In-Reply-To: <516D8649.4030604@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 21:11 +0400, Sergei Shtylyov wrote:
> On 16-04-2013 19:22, Fabio Estevam wrote:
> >>> +static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
> >>> +#define FEC_PM_OPS (&fec_pm_ops)
> >>     Nit: parens are useless here.

Is this macro indirection even useful?

Using &fec_pm_ops seems quite readable.
