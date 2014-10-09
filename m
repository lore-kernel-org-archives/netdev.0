From: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Subject: RE: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Thu, 9 Oct 2014 07:11:23 +0000
Message-ID: <d02538a4332d468d93a142cdffc7d037@BY2PR03MB441.namprd03.prod.outlook.com>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy> <20141001035900.GA4544@netboy>
 <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008080603.GA4648@netboy>
 <d9c981e97dae416488b45b06f7384471@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008101309.GA15020@netboy>
 <482a8065ead14cb5afab87c7934d8031@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141009065257.GA4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0115.outbound.protection.outlook.com ([157.56.111.115]:37115
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750815AbaJIHL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 03:11:27 -0400
In-Reply-To: <20141009065257.GA4042@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 02:53:00PM +8000, Richard Cochran wrote:

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, October 09, 2014 2:53 PM
> To: Zhou Luwei-B45643
> Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org;
> bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
> Frank-B20596; stephen@networkplumber.org
> Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding
> doc
> 
> On Thu, Oct 09, 2014 at 02:19:07AM +0000, luwei.zhou@freescale.com wrote:
> > Since there are 4 channels in the PTP timer IP and none of 4 channels
> > Is now used by now. We can use hardcode to define the default PPS
> > output channel not DT such as "#define PPS_COUTPUT_CHANNEL
> FEC_TIMER_CHANNEL0".
> 
> I prefer this to a random new DT property, but how can you be sure that
> nothing else in the kernel is using FEC_TIMER_CHANNELx?
> 
> Thanks,
> Richard

The channel related registers in PTP timers are not defined in the Ethernet driver. Current
Code just use ptp timer timestamp function to support linux ptp. So I conclude that we can
Choose one channel as default.

Thanks
Luwei
