From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: RE: [PATCH v5] ixgbe: Add module parameter to disable VLAN filter
Date: Fri, 22 May 2015 00:54:31 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB4CA5@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB460C@BPXM14GP.gisp.nec.co.jp>
 <20150521.120713.1811144256149554543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"sy.jong.choi@intel.com" <sy.jong.choi@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150521.120713.1811144256149554543.davem@davemloft.net>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Subject: Re: [PATCH v5] ixgbe: Add module parameter to disable VLAN filter
> 
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Date: Thu, 21 May 2015 13:10:49 +0000
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index 263cb40..b45570f 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -158,6 +158,10 @@ module_param(allow_unsupported_sfp, uint, 0);
> >  MODULE_PARM_DESC(allow_unsupported_sfp,
> >  		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
> >
> > +static unsigned int disable_hw_vlan_filter;
> > +module_param(disable_hw_vlan_filter, uint, 0);
> > +MODULE_PARM_DESC(disable_hw_vlan_filter, "Disable HW VLAN filter");
> 
> Sorry, module parameters like this are not allowed.
> 
> You must use a generic, portable interface, to configure networking
> device settings.

Could you please tell me which interface is good for this?

> 
> Otherwise every other driver that wants to do something similar will
> have yet another module option with a different name, and every user
> will suffer because they will need to learn a different mechanism
> to perform this configuration for every driver.

Right, I agree.
But I thought that this requirement seems really special and closed in
ixgbe driver, that the reason I tried it with module parameter.

thanks,
Hiroshi
