From: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Subject: RE: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Thu, 9 Oct 2014 02:19:07 +0000
Message-ID: <482a8065ead14cb5afab87c7934d8031@BY2PR03MB441.namprd03.prod.outlook.com>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy> <20141001035900.GA4544@netboy>
 <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008080603.GA4648@netboy>
 <d9c981e97dae416488b45b06f7384471@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008101309.GA15020@netboy>
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
Received: from mail-by2on0147.outbound.protection.outlook.com ([207.46.100.147]:34875
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751261AbaJICTL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 22:19:11 -0400
In-Reply-To: <20141008101309.GA15020@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 8, 2014 at 06:13:00PM, Richard Cochran wrote:
> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Wednesday, October 08, 2014 6:13 PM
> To: Zhou Luwei-B45643
> Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org;
> bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
> Frank-B20596; stephen@networkplumber.org
> Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding
> doc
> 
> On Wed, Oct 08, 2014 at 08:36:11AM +0000, luwei.zhou@freescale.com wrote:
> >
> > I am not expert in DT.
> 
> (Me neither ;)
> 
> > I didn't get your point of using timer resource in the DT.  Yes, the
> > timer resource is Part of FEC IP hardware. But if you want to choose
> > one channel for using PPS, you have to add another property to specify.
> Do you mean the current code already have the DT property to specify the
> channel?
> 
> I see some timer bindings in Documentation/devicetree/bindings/timer.
> So, you could and should add your SoC timer there and in the DTS files.
> 
> Then, you have something like
> 
> 	@fec {
> 		pps_timer = &timer;
> 	}
> 
> in your SoC's DTS file.
> 
> Thanks,
> Richard

I know what you meant now. If using similar way, it seems that we still need the new property in the timer node below.

@timer
{
	pps_channel = 0;
}
I didn't find out the exiting channel related property in the Documentation.

Since there are 4 channels in the PTP timer IP and none of 4 channels
Is now used by now. We can use hardcode to define the default PPS output channel not DT such as 
"#define PPS_COUTPUT_CHANNEL FEC_TIMER_CHANNEL0". 

Thanks
Luwei
