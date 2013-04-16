From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 14:51:27 -0300
Message-ID: <CAOMZO5ArAZjXko5_XT4m-aq8QhTHYzUue+7Vyo8dPTwW4pbv4Q@mail.gmail.com>
References: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
	<516D60E0.6000107@cogentembedded.com>
	<CAOMZO5CGn=aetDoo-oc3Ub3ZL=8RKsPzH6jkXvifykSnWrV_Rg@mail.gmail.com>
	<516D8649.4030604@cogentembedded.com>
	<1366134545.28609.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:46887 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936039Ab3DPRv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 13:51:28 -0400
Received: by mail-vc0-f169.google.com with SMTP id hx10so622866vcb.14
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 10:51:27 -0700 (PDT)
In-Reply-To: <1366134545.28609.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 2:49 PM, Joe Perches <joe@perches.com> wrote:

> Is this macro indirection even useful?

Yes, it is useful. Please check the patch context. We use a define to
distinguish between the CONFIG_PM_SLEEP
and !CONFIG_PM_SLEEP
