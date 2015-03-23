From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH net-next V2 20/23] ptp: dp83640: convert to the 64 bit get/set time methods.
Date: Mon, 23 Mar 2015 16:06:28 +0100
Message-ID: <201503231606.29346.arnd@linaro.org>
References: <cover.1426973658.git.richardcochran@gmail.com> <201503221848.02226.arnd@linaro.org> <20150323081040.GA4779@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Stefan =?iso-8859-1?q?S=F8rensen?=
	<stefan.sorensen@spectrali
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323081040.GA4779@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 23 March 2015, Richard Cochran wrote:
> 
> On Sun, Mar 22, 2015 at 06:48:02PM +0100, Arnd Bergmann wrote:
> > Ok, got it. The code looks correct then, though I'd like to see the use
> > of 'timespec' pushed out as far as possible. How about changing the
> > type for tdr_write() as well here?
> > 
> > tdr_write() itself should be fine until 2106, as it writes an unsigned number,
> > but it's probably good to document that inside of that function.
> 
> Arnd, thanks for the careful review.  I will work out follow up
> patches for this driver and the i210 (igb) to address the remaining
> issues.  For this series, lets leave tdr_write as is now, but I will
> surely take another look for the fix.
> 

Ok, sounds good.

	Arnd
