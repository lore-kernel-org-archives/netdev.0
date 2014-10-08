From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Wed, 8 Oct 2014 10:06:03 +0200
Message-ID: <20141008080603.GA4648@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy>
 <20141001035900.GA4544@netboy>
 <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
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
Received: from mail-wg0-f47.google.com ([74.125.82.47]:54464 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbaJHIGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 04:06:10 -0400
Received: by mail-wg0-f47.google.com with SMTP id x13so10933014wgg.18
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 01:06:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <39bcecf4ec1a4862bc7316dc845a535c@BY2PR03MB441.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2014 at 03:15:08AM +0000, luwei.zhou@freescale.com wrote:
> On Wed, Oct 1, 2014 at 11:59:00AM, Richard Cochran wrote:
> > -----Original Message-----
> > From: Richard Cochran [mailto:richardcochran@gmail.com]
> > Sent: Wednesday, October 01, 2014 11:59 AM
> > To: Zhou Luwei-B45643
> > Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org;
> > bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
> > Frank-B20596; stephen@networkplumber.org
> > Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding
> > doc
> > 
> > On Thu, Sep 25, 2014 at 04:43:50PM +0200, Richard Cochran wrote:
> > > On Thu, Sep 25, 2014 at 04:10:21PM +0800, Luwei Zhou wrote:
> > > > This patch update fec devicetree binding doc that add Optional
> > > > properties "pps-channel".
> > >
> > > Again, use the PTP pin interface. We don't need a random new FEC DT
> > > property for this.
> > 
> > BTW, if the "channel" only means an internal timer resource, please find
> > a proper way to claim that resource. Do not add another random DT
> > property. We have enough of those already.
> > 
> > Thanks,
> > Richard
> 
> Okay. I will use the PTP pin interface to let user set the channel index as V2 patch does. Sorry for the
> late reply caused by vocation.

Do not use the PTP pin control for an internal PPS event. Instead,
just claim the timer as some kind of internal resource. It looks like
timers are already part of DT, so why not use those?

Thanks,
Richard
