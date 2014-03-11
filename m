From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC net-next v1 1/9] ptp: introduce programmable pins.
Date: Tue, 11 Mar 2014 11:08:19 +0100
Message-ID: <20140311100818.GA4266@netboy>
References: <cover.1394307303.git.richardcochran@gmail.com>
 <d9cb37a7d6e57d7f103dab78f98044697d3c4433.1394307304.git.richardcochran@gmail.com>
 <F85F72BA1EE25F8F7FB77295@[172.22.2.41]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F85F72BA1EE25F8F7FB77295@[172.22.2.41]>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 08:58:45AM +0100, Christian Riesch wrote:
> >+	if (pin1 && pin1->func == PTP_PF_PHYSYNC) {
> >+		pr_err("sorry, cannot reprogram the calibration pin\n");
> >+		return -EINVAL;
> 
>            ^^^^
> Will this ever happen? pin1 && pin1->func == PTP_PF_PHYSYNC means
> that func == PTP_PF_PHYSYNC, but in this case you already return
> -EINVAL a few lines above.

This a bug. I really meant to test (pin2->func == PTP_PF_PHYSYNC) to
prevent clobbering the calibration function with some other function.
I'll fix it for v2.

Thanks,
Richard
