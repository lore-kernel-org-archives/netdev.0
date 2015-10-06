From: Arun Parameswaran <aparames-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 4/5] net: phy: Broadcom Cygnus internal Etherent PHY
 driver
Date: Tue, 6 Oct 2015 11:56:06 -0700
Message-ID: <56141946.4090801@broadcom.com>
References: <201510011203.PcAeqiTE%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "kbuild-all-JC7UmRfGjtg@public.gmane.org" <kbuild-all-JC7UmRfGjtg@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm-kernel-feedback-list <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201510011203.PcAeqiTE%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 15-09-30 09:04 PM, kbuild test robot wrote:
> Hi Arun,
>
> [auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]
>
> config: um-allyesconfig (attached as .config)
> reproduce:
>         git checkout 0560b94805aa3bb38439b4f72b776d85d2aac394
>         # save the attached .config to linux build tree
>         make ARCH=um 
>
> All warnings (new ones prefixed by >>):
>
> warning: (BCM_CYGNUS_PHY) selects MDIO_BCM_IPROC which has unmet direct dependencies (NETDEVICES && PHYLIB && (ARCH_BCM_IPROC || COMPILE_TEST) && HAS_IOMEM && OF_MDIO)

Fixing this warning.
Changing from 'select MDIO_BCM_IPROC' to using 'depends on MDIO_BCM_IPROC' in the Cygnus PHY driver.

> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
