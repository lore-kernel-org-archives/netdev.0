From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH net-next v3 2/2] macb: Enable 1588 support in SAMA5Dx
 platforms.
Date: Wed, 7 Dec 2016 20:43:32 +0100
Message-ID: <20161207194332.GB13062@netboy>
References: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
 <1481134912-2243-2-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tbultel@pixelsurmer.com, boris.brezillon@free-electrons.com,
 rafalo@cadence.com, netdev@vger.kernel.org,
 alexandre.belloni@free-electrons.com, nicolas.ferre@atmel.com,
 linux-kernel@vger.kernel.org, harinikatakamlinux@gmail.com, michals@xilinx.com,
 anirudh@xilinx.com, punnaia@xilinx.com, harini.katakam@xilinx.com,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1481134912-2243-2-git-send-email-andrei.pistirica@microchip.com>
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

On Wed, Dec 07, 2016 at 08:21:52PM +0200, Andrei Pistirica wrote:
> +static int gem_hwtst_set(struct net_device *netdev,
> +			 struct ifreq *ifr, int cmd)
> +{

...

> +	switch (config.rx_filter) {
> +	case HWTSTAMP_FILTER_NONE:
> +		if (priv->hwts_rx_en)
> +			priv->hwts_rx_en = 0;
> +		break;
> +	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
> +	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
> +	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
> +	case HWTSTAMP_FILTER_ALL:
> +	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
> +	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
> +	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
> +	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
> +	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
> +	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
> +	case HWTSTAMP_FILTER_PTP_V2_EVENT:
> +	case HWTSTAMP_FILTER_PTP_V2_SYNC:
> +	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
> +		config.rx_filter = HWTSTAMP_FILTER_ALL;

Does the device really time stamp all packets?

Or did you mean "all PTP packets?  For that, use
HWTSTAMP_FILTER_PTP_V2_EVENT.

Thanks,
Richard
