From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [PATCH v5] can: Convert to runtime_pm
Date: Wed, 28 Jan 2015 15:19:24 +0000
Message-ID: <1ae6a3ca4fad4104a673b9a6c7e44998@BY2FFO11FD036.protection.gbl>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
 <54C8F62D.6090909@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, "wg@grandegger.com"
 <wg@grandegger.com>, Michal Simek <michals@xilinx.com>, Soren Brinkmann
 <sorenb@xilinx.com>, "grant.likely@linaro.org" <grant.likely@linaro.org>,
 "robh+dt@kernel.org" <robh+dt@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <54C8F62D.6090909@pengutronix.de>
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

Hi Marc,

> -----Original Message-----
> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
> Sent: Wednesday, January 28, 2015 8:16 PM
> To: Appana Durga Kedareswara Rao; wg@grandegger.com; Michal Simek;
> Soren Brinkmann; grant.likely@linaro.org; robh+dt@kernel.org
> Cc: linux-can@vger.kernel.org; netdev@vger.kernel.org; linux-arm-
> kernel@lists.infradead.org; linux-kernel@vger.kernel.org;
> devicetree@vger.kernel.org; Appana Durga Kedareswara Rao
> Subject: Re: [PATCH v5] can: Convert to runtime_pm
>
> On 01/12/2015 04:04 PM, Kedareswara rao Appana wrote:
> > Instead of enabling/disabling clocks at several locations in the
> > driver, Use the runtime_pm framework. This consolidates the actions
> > for runtime PM In the appropriate callbacks and makes the driver more
> readable and mantainable.
> >
> > Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> > Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > ---
> > Changes for v5:
> >  - Updated with the review comments.
> >    Updated the remove fuction to use runtime_pm.
> > Chnages for v4:
> >  - Updated with the review comments.
> > Changes for v3:
> >   - Converted the driver to use runtime_pm.
> > Changes for v2:
> >   - Removed the struct platform_device* from suspend/resume
> >     as suggest by Lothar.
>
> Any plans to submit a v6?

I was on vacation till yesterday just came to office today only. Will look into it and will send v6 at the earliest.

Regards,
Kedar.

>
> Marc
> --
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.
