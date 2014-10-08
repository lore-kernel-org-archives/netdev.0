From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Wed, 8 Oct 2014 12:13:09 +0200
Message-ID: <20141008101309.GA15020@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy>
 <20141001035900.GA4544@netboy>
 <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008080603.GA4648@netboy>
 <d9c981e97dae416488b45b06f7384471@BY2PR03MB441.namprd03.prod.outlook.com>
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
Received: from mail-wg0-f43.google.com ([74.125.82.43]:51570 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbaJHKNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 06:13:14 -0400
Received: by mail-wg0-f43.google.com with SMTP id m15so11126761wgh.2
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 03:13:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d9c981e97dae416488b45b06f7384471@BY2PR03MB441.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2014 at 08:36:11AM +0000, luwei.zhou@freescale.com wrote:
> 
> I am not expert in DT.

(Me neither ;)

> I didn't get your point of using timer resource in the DT.  Yes, the timer resource is
> Part of FEC IP hardware. But if you want to choose one channel for using PPS, you have to add another property
> to specify. Do you mean the current code already have the DT property to specify the channel?

I see some timer bindings in Documentation/devicetree/bindings/timer.
So, you could and should add your SoC timer there and in the DTS
files.

Then, you have something like

	@fec {
		pps_timer = &timer;
	}

in your SoC's DTS file.

Thanks,
Richard
