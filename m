From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Thu, 13 Mar 2014 19:21:12 +0800
Message-ID: <20140313112112.GB8806@localhost>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local>
 <531DD493.3030306@monstr.eu>
 <531DD5E7.7090406@pengutronix.de>
 <3245971.RIuVmbVL0Z@wuerfel>
 <1964213d-6bd9-49fa-805e-42e1e0630fd5@VA3EHSMHS029.ehs.local>
 <20140311044555.GA12373@localhost>
 <546dbc60-dd7b-4249-bab8-ad7e008b9aad@AM1EHSMHS001.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Marc Kleine-Budde <mkl@pengutronix.de>, monstr@monstr.eu,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	robh+dt@kernel.org,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	grant.likely@linaro.org,
	Kedareswara rao Appana <appanad@xilinx.com>,
	wg@grandegger.com
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <546dbc60-dd7b-4249-bab8-ad7e008b9aad@AM1EHSMHS001.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michal,

On Tue, Mar 11, 2014 at 10:38:14AM +0100, Michal Simek wrote:
> On 03/11/2014 05:45 AM, Fengguang Wu wrote:
> >>> You probably want something like
> >>>
> >>> 	config CAN_XILINX
> >>> 	tristate "Xilinx CAN"
> >>> 	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
> >>> 	depends on COMMON_CLK && HAS_MMIO  # whatever you need for other architectures
> >>
> >> Fengguang: Are you use COMPILE_TEST in zero day testing system?
> > 
> > Yeah, the randconfig build/boot tests should cover both COMPILE_TEST
> > and !COMPILE_TEST cases.
> 
> But the point is that randconfig is really random it means it definitely can
> cover but not there is no certainty that for that build, you are running,
> has both option for all architectures enabled.
> Or do I read it wrongly?

Good point!  Since the 0day system is running randconfig tests
everyday, it has very good opportunity to cover the COMPILE_TEST case.
But to be sure, I'll explicitly enable COMPILE_TEST in some cases.

Thanks,
Fengguang
