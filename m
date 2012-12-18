From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/4] FEC: Add time stamping code and a PTP hardware clock
Date: Tue, 18 Dec 2012 08:04:20 +0100
Message-ID: <20121218070420.GA2946@netboy.at.omicron.at>
References: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
 <20121217091345.GA753@pengutronix.de>
 <CAHrpEqTVuSR_-Tpdzb98=VJbg7grSFvSQ9xA6mPsHpGb7RvNCg@mail.gmail.com>
 <20121217151445.GA17907@S2101-09.ap.freescale.net>
 <20121217200232.GS26326@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org, lznua@gmail.com,
 Frank Li <lznuaa@gmail.com>, Shawn Guo <shawn.guo@linaro.org>,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20121217200232.GS26326@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 17, 2012 at 09:02:32PM +0100, Sascha Hauer wrote:
> This leaves an option in the tree which can be used to break FEC on
> i.MX3/5.
> 
> 	depends on !SOC_IMX31 && !SOC_IMX35 && !SOC_IMX5
> 
> might be an option, but given that this patch seems to have bypassed any
> review I feel more like reverting it.

Instead of reverting, I suggest finding a solution (Frank) to let the
code work when it can work and to prevent it when it cannot. This
could be kconfig, DT, or run time probing of silicon revisions, but I
don't have access to this hardware, and so I can't really say how to
fix it.

Just for the record, I did in fact review this patch, and I commented
on exactly this point. Frank said we would address this point, and he
did so. Not knowing the imx family very well, I took his word for it.
After all, Frank has a Freescale address, and I would expect a
Freescale employee to know how to provide the right fix.

Thanks,
Richard
