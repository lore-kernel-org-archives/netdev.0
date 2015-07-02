From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: RE: macb: zynq: why is SG disabled?
Date: Thu, 2 Jul 2015 02:33:14 +0000
Message-ID: <03CA77BA8AF6F1469AEDFBDA1322A7B7495B9EE3@XAP-PVEXMBX02.xlnx.xilinx.com>
References: <559403E3.3050900@certsign.ro> <55941D80.2090904@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>, Nicolae Rosia
 <nicolae.rosia@certsign.ro>, Michal Simek <michals@xilinx.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Nicolas Ferre
 <nicolas.ferre@atmel.com>, "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <55941D80.2090904@atmel.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Nicolae and Cyrille,

   SG feature was not tested for Zynq using macb driver but tested it using=
 the
 emacps Driver in Xilinx tree (this driver is deprecated recently)

We will test and enable this feature in driver for Zynq.

Regards,
Punnaiah

> -----Original Message-----
> From: Cyrille Pitchen [mailto:cyrille.pitchen@atmel.com]
> Sent: Wednesday, July 01, 2015 10:34 PM
> To: Nicolae Rosia; Michal Simek; Punnaiah Choudary Kalluri;
> netdev@vger.kernel.org; Nicolas Ferre; linux-arm-kernel@lists.infradead.o=
rg
> Subject: Re: macb: zynq: why is SG disabled?
> =

> Le 01/07/2015 17:14, Nicolae Rosia a =E9crit :
> > Hello,
> >
> > After reading the GEM part of Zynq7000 Technical Reference Manual [0], I
> think that SG should be supported.
> > Is there a reason why SG is disabled in macb for Zynq?
> >
> > Best regards,
> > Nicolae Rosia
> =

> Hi Nicolae,
> =

> when the scatter-gather patch was introduced, the feature was enabled only
> on tested boards to avoid regressions on other boards.
> So SG is enabled on sama5d4x and sama5d2x SoCs. SG is disabled on purpose
> on sama5d3x.
> =

> For Zynq, I think the feature is still disabled just because it has never=
 been
> tested.
> =

> Best regards,
> =

> Cyrille
