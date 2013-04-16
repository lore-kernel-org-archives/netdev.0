From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 12:22:00 -0300
Message-ID: <CAOMZO5CGn=aetDoo-oc3Ub3ZL=8RKsPzH6jkXvifykSnWrV_Rg@mail.gmail.com>
References: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
	<516D60E0.6000107@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fabio Estevam <fabio.estevam@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Joe Perches <joe@perches.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:33515 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824Ab3DPPWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 11:22:01 -0400
Received: by mail-vc0-f181.google.com with SMTP id ia10so494725vcb.12
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 08:22:00 -0700 (PDT)
In-Reply-To: <516D60E0.6000107@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:32 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:

>> +static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
>> +#define FEC_PM_OPS (&fec_pm_ops)
>
>
>    Nit: parens are useless here.

Have you tried removing parenthesis and run checkpatch?

ERROR: Macros with complex values should be enclosed in parenthesis
#45: FILE: drivers/net/ethernet/freescale/fec_main.c:1950:
+#define FEC_PM_OPS &fec_pm_ops
