From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 21:11:37 +0400
Message-ID: <516D8649.4030604@cogentembedded.com>
References: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com> <516D60E0.6000107@cogentembedded.com> <CAOMZO5CGn=aetDoo-oc3Ub3ZL=8RKsPzH6jkXvifykSnWrV_Rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <fabio.estevam@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Joe Perches <joe@perches.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:50242 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965014Ab3DPRMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 13:12:46 -0400
Received: by mail-la0-f44.google.com with SMTP id fr10so683157lab.17
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 10:12:45 -0700 (PDT)
In-Reply-To: <CAOMZO5CGn=aetDoo-oc3Ub3ZL=8RKsPzH6jkXvifykSnWrV_Rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 16-04-2013 19:22, Fabio Estevam wrote:

>>> +static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
>>> +#define FEC_PM_OPS (&fec_pm_ops)

>>     Nit: parens are useless here.

> Have you tried removing parenthesis and run checkpatch?

    Oops, I haven't.

> ERROR: Macros with complex values should be enclosed in parenthesis
> #45: FILE: drivers/net/ethernet/freescale/fec_main.c:1950:
> +#define FEC_PM_OPS &fec_pm_ops

   Didn't know about this, sorry for the noise.

WBR, Sergei
