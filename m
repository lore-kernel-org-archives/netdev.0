From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 13/23] ptp: igb: convert to the 64 bit
 get/set time methods.
Date: Thu, 2 Apr 2015 08:33:35 +0200
Message-ID: <20150402063335.GB4248@localhost.localdomain>
References: <cover.1427662906.git.richardcochran@gmail.com>
 <67fa71b28f96b222c8027b49efee4144b3754bf7.1427662907.git.richardcochran@gmail.com>
 <20150331215317.GA9339@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB58574FB888@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare lin
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35584 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbDBGdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 02:33:42 -0400
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB58574FB888@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 12:06:56AM +0000, Keller, Jacob E wrote:
> I don't know how kernel would fix this. Usually macros like PRI64d are used but I am not sure those are defined for the kernel builds

Davem fixed it by casting to (long long).

Thanks,
Richard
