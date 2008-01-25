From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: RE: [PATCH UCC TDM 3/3 ] Modified Documentation to explain dtsentries
	for TDM driver
Date: Fri, 25 Jan 2008 09:28:19 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C279AFF5@zin33exm24.fsl.freescale.net>
References: <Pine.LNX.4.64.0801241022070.27491@linux121>
	<20080124201226.GA3926@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Barkowski Michael <Michael.Barkowski@freescale.com>, netdev@vger.kernel.org,
	Gala Kumar <kumar.gala@freescale.com>,
	linux-kernel@vger.kernel.org, rubini@vision.unipv.it,
	linuxppc-dev@ozlabs.org, Kalra Ashish <ashish.kalra@freescale.com>,
	Cutler Richard <Rich.Cutler@freescale.com>,
	akpm@linux-foundation.org, Tabi Timur <timur@freescale.com>
To: "Wood Scott" <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080124201226.GA3926@loki.buserror.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi Scott

The device tree already has a brg-frequency  property in qe node which
is the value of BRGCLK. The function get_brg_clk uses this property to
find the value of BRGCLK.
In case this value is 0(some older u-boots populate bus-frequency
property of qe and not the brg-frequency), get_brg_clk  uses
bus-frequency/2 as BRGCLK.


With Regards
Poonam 
 
 

-----Original Message-----
From: Wood Scott 
Sent: Friday, January 25, 2008 1:42 AM
To: Aggrwal Poonam
Cc: Gala Kumar; akpm@linux-foundation.org; linux-kernel@vger.kernel.org;
netdev@vger.kernel.org; rubini@vision.unipv.it; linuxppc-dev@ozlabs.org;
Barkowski Michael; Cutler Richard; Tabi Timur; Kalra Ashish
Subject: Re: [PATCH UCC TDM 3/3 ] Modified Documentation to explain
dtsentries for TDM driver

On Thu, Jan 24, 2008 at 10:24:13AM +0530, Poonam_Aggrwal-b10812 wrote:
> +  ix) Baud Rate Generator (BRG)
> +
> +  Required properties:
> +  - compatible : shpuld be "fsl,cpm-brg"
> +  - fsl,brg-sources : define the input clock for all 16 BRGs. The
input
> +    clock source could be 1 to 24 for CLK1 to CLK24. Zero means that
the
> +    particular BRG will be driven by QE clock(BRGCLK).

Should also have a clock-frequency property to specify what BRGCLK is.

-Scott
