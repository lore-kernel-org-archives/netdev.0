From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 05 Nov 2015 13:31:31 -0500 (EST)
Message-ID: <20151105.133131.1900833527415923596.davem@davemloft.net>
References: <20151105.103126.148818796422971143.davem@davemloft.net>
	<20151105.110506.1901401372160830603.davem@davemloft.net>
	<CAHp75VfiV6DVb-2piCxmEWFP4Gi-+n0qNhhscvd=UsqXrivVYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: andy.shevchenko@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VfiV6DVb-2piCxmEWFP4Gi-+n0qNhhscvd=UsqXrivVYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 5 Nov 2015 20:13:21 +0200

> What about
> 
> if (!addr)
>  return -ENODATA;

I totally disagree.  of_get_phy_mode() and other similar attribute
probing mechanisms use -ENODEV.
