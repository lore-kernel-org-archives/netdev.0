From: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Subject: RE: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Wed, 8 Oct 2014 08:36:11 +0000
Message-ID: <d9c981e97dae416488b45b06f7384471@BY2PR03MB441.namprd03.prod.outlook.com>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy> <20141001035900.GA4544@netboy>
 <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
 <20141008080603.GA4648@netboy>
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
Received: from mail-bn1on0139.outbound.protection.outlook.com ([157.56.110.139]:30528
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752071AbaJHIgT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 04:36:19 -0400
In-Reply-To: <20141008080603.GA4648@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 8, 2014 at 4:06:00AM, Richard Cochran wrote:
> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Wednesday, October 08, 2014 4:06 PM
> To: Zhou Luwei-B45643
> Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org;
> bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
> Frank-B20596; stephen@networkplumber.org
> Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding
> doc
> 
> On Wed, Oct 08, 2014 at 03:15:08AM +0000, luwei.zhou@freescale.com wrote:
> > On Wed, Oct 1, 2014 at 11:59:00AM, Richard Cochran wrote:
> > > -----Original Message-----
> > > From: Richard Cochran [mailto:richardcochran@gmail.com]
> > > Sent: Wednesday, October 01, 2014 11:59 AM
> > > To: Zhou Luwei-B45643
> > > Cc: davem@davemloft.net; netdev@vger.kernel.org;
> > > shawn.guo@linaro.org; bhutchings@solarflare.com; Estevam
> > > Fabio-R49496; Duan Fugang-B38611; Li Frank-B20596;
> > > stephen@networkplumber.org
> > > Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts
> > > binding doc
> > >
> > > On Thu, Sep 25, 2014 at 04:43:50PM +0200, Richard Cochran wrote:
> > > > On Thu, Sep 25, 2014 at 04:10:21PM +0800, Luwei Zhou wrote:
> > > > > This patch update fec devicetree binding doc that add Optional
> > > > > properties "pps-channel".
> > > >
> > > > Again, use the PTP pin interface. We don't need a random new FEC
> > > > DT property for this.
> > >
> > > BTW, if the "channel" only means an internal timer resource, please
> > > find a proper way to claim that resource. Do not add another random
> > > DT property. We have enough of those already.
> > >
> > > Thanks,
> > > Richard
> >
> > Okay. I will use the PTP pin interface to let user set the channel
> > index as V2 patch does. Sorry for the late reply caused by vocation.
> 
> Do not use the PTP pin control for an internal PPS event. Instead, just
> claim the timer as some kind of internal resource. It looks like timers
> are already part of DT, so why not use those?
> 
> Thanks,
> Richard

Hi Richard,

I am not expert in DT.I didn't get your point of using timer resource in the DT.  Yes, the timer resource is
Part of FEC IP hardware. But if you want to choose one channel for using PPS, you have to add another property
to specify. Do you mean the current code already have the DT property to specify the channel?

Thanks
Luwei
