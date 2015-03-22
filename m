From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 04/23] ptp: blackfin: convert to the 64 bit
 get/set time methods.
Date: Sun, 22 Mar 2015 08:27:34 +0100
Message-ID: <20150322072734.GA4254@localhost.localdomain>
References: <cover.1426973658.git.richardcochran@gmail.com>
 <d60e40f5c008cf85a764f958d5b692f167cd05ba.1426973658.git.richardcochran@gmail.com>
 <201503220328.46415.arnd@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectrali
To: Arnd Bergmann <arnd@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36118 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbCVH1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:27:41 -0400
Content-Disposition: inline
In-Reply-To: <201503220328.46415.arnd@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 03:28:46AM +0100, Arnd Bergmann wrote:
> I think it would be good to replace the open-coded 
> 
>         ns = ts->tv_sec * 1000000000ULL;
>         ns += ts->tv_nsec;
> 
> here with a call to ns_to_timespec64(), here and in other drivers that you
> are already touching.

Yes, I'll do that as a follow on series.

Thanks,
Richard
