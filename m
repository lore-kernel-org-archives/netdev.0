From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 14 Apr 2015 07:27:29 +0200
Message-ID: <20150414052729.GA5179@netboy>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
 <20150328082853.GA4255@localhost.localdomain>
 <5519D380.6070200@cogentembedded.com>
 <552C25BE.3070606@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	masaru.nagai.vx@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552C25BE.3070606@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2015 at 11:23:26PM +0300, Sergei Shtylyov wrote:
> >>This is a bit hacky.  Can't your driver make sure that the HW is ready?
> 
> >    Will look into this. Perhaps it's a remainder from when the PTP driver was
> >separate...
> 
>    No, we enter this mode upon closing the Ethernet device and when
> the ring DMA sizes are changed. Seems unavoidable...
> 
> >>>+    if (ravb_read(priv->ndev, CSR) & CSR_OPS_CONFIG)
> >>>+        return true;
> >>>+    else
> >>>+        return false;

It is surely avoidable.  The driver knows (or should know) whether or
not the hardware has been configured or not.

Thanks,
Richard
