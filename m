From: Qiang Zhao <qiang.zhao@nxp.com>
Subject: RE: [PATCH 4/5] fsl/qe: Add QE TDM lib
Date: Thu, 31 Mar 2016 01:25:11 +0000
Message-ID: <AM3PR04MB11852B1F60CE58F0A877969291990@AM3PR04MB1185.eurprd04.prod.outlook.com>
References: <1459327830-19829-1-git-send-email-qiang.zhao@nxp.com>
	 <1459327830-19829-4-git-send-email-qiang.zhao@nxp.com>
 <1459338701.3538.17.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"oss@buserror.net" <oss@buserror.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459338701.3538.17.camel@infinera.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-03-30 at 07:50PM, Joakim Tjernlund wrote:
> -----Original Message-----
> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@infinera.com]
> Sent: Wednesday, March 30, 2016 7:50 PM
> To: davem@davemloft.net; Qiang Zhao <qiang.zhao@nxp.com>
> Cc: linuxppc-dev@lists.ozlabs.org; linux-kernel@vger.kernel.org; Xiaobo Xie
> <xiaobo.xie@nxp.com>; oss@buserror.net; gregkh@linuxfoundation.org;
> akpm@linux-foundation.org; netdev@vger.kernel.org
> Subject: Re: [PATCH 4/5] fsl/qe: Add QE TDM lib
> 
> On Wed, 2016-03-30 at 16:50 +0800, Zhao Qiang wrote:
> > QE has module to support TDM, some other protocols supported by QE are
> > based on TDM.
> > add a qe-tdm lib, this lib provides functions to the protocols using
> > TDM to configurate QE-TDM.
> >
> > Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
> > +	utdm->siram_entry_id = val;
> > +
> > +	set_si_param(utdm, ut_info);
> > +
> > +	np2 = of_find_compatible_node(NULL, NULL, "fsl,t1040-qe-si");
> 
> fsl,t1040-qe-si only? What about mpc83xx?
> I recall QE is a little bit different compared to T1040 or will this work(including
> the hdlc driver) on 83xx as well?

The " fsl,t1040-qe-si " is new added to dts and bindings, it is required to have SoC specific compatible strings.
mpc83xx will not use qe-si node. If there will be other soc useing qe-si, " fsl,t1040-qe-si " will follow the soc specific compatible,
like : 
                si1: si@700 {
                        compatible = "fsl,ls1043-qe-si", "fsl,t1040-qe-si";
                        reg = <0x700 0x80>;
                };

Best Regards
Zhao Qiang
