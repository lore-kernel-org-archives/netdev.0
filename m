From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Tue, 6 Dec 2016 00:11:54 +0100
Message-ID: <1308df56-e85b-beb0-04d0-ffe482f1a82b@gmx.de>
References: <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd> <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161205101516.GA24936@amd>
 <trinity-efd00e93-2b37-4543-a199-e2cbed9fe455-1480937999976@3capp-gmx-bs18>
 <20161205220221.GA19135@amd> <9a85da24-85cf-f94e-908f-a10eecac2369@gmx.de>
 <20161205224057.GB19135@amd> <98fb3577-5f31-bf17-3e02-96c150854108@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <98fb3577-5f31-bf17-3e02-96c150854108@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> You mean stmmac_xmit()? Thats also softirq AFAICT, its the TX softirq....
> 
> Regards,
> Lino
> 
> 

Hmm. netdevices.txt says:

ndo_start_xmit:
	...

	Context: Process with BHs disabled or BH (timer),
	         will be called with interrupts disabled by netconsole.

	...

If this is correct it can indeed be process context, too. However BHs are already
disabled.
