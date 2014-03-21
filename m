From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/9] ptp: dynamic pin control
Date: Fri, 21 Mar 2014 14:22:00 -0400 (EDT)
Message-ID: <20140321.142200.844343833964886553.davem@davemloft.net>
References: <cover.1395350105.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@decadent.org.uk, christian.riesch@omicron.at,
	stefan.sorensen@spectralink.com
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395350105.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 20 Mar 2014 22:21:51 +0100

> This patch series introduces a way of changing the auxiliary PTP
> Hardware Clock functions (periodic output signals and time stamping
> external signals) at run time. In the past on the netdev list, we have
> discussed other ways to handle this, such as module parameters and
> ethtool. This series implements a new PHC ioctl because that is the
> most natural way. Users already activate the auxiliary functions via
> the ioctls. The sysfs interface has also been expanded so that the pin
> configuration can be programmed using shell scripts.
> 
> The first patch adds the new ioctls. The PHC subsystem does most of
> the work of maintaining the function-to-pin mapping. Drivers will only
> need to allocate and initialize a pin configuration table and also
> provide a new method that validates a particular assignment.
> 
> Patches 5 and 6 just clean up a couple of issues in the phyter driver,
> and the remaining patches actually hook the phyter's pins into the new
> system.
> 
> Comments and questions are most welcome.

Series applied, thanks Richard.
