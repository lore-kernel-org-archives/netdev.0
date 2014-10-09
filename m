From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Thu, 9 Oct 2014 08:52:57 +0200
Message-ID: <20141009065257.GA4042@localhost.localdomain>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy>
 <20141001035900.GA4544@netboy>
 <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008080603.GA4648@netboy>
 <d9c981e97dae416488b45b06f7384471@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008101309.GA15020@netboy>
 <482a8065ead14cb5afab87c7934d8031@BY2PR03MB441.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:52450 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbaJIGxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 02:53:03 -0400
Received: by mail-wi0-f177.google.com with SMTP id fb4so846756wid.4
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 23:53:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <482a8065ead14cb5afab87c7934d8031@BY2PR03MB441.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 02:19:07AM +0000, luwei.zhou@freescale.com wrote:
> Since there are 4 channels in the PTP timer IP and none of 4 channels
> Is now used by now. We can use hardcode to define the default PPS output channel not DT such as 
> "#define PPS_COUTPUT_CHANNEL FEC_TIMER_CHANNEL0". 

I prefer this to a random new DT property, but how can you be sure
that nothing else in the kernel is using FEC_TIMER_CHANNELx?

Thanks,
Richard
