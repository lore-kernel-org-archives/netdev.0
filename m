From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Fri, 30 Oct 2015 14:12:54 -0400
Message-ID: <20151030181254.GC32759@oracle.com>
References: <20151030150344.GG9312@oracle.com>
 <CAHp75Vc-swMap+Umong1WVfL-fQNNZ9QEXvrHCJXCte1g_h_KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHp75Vc-swMap+Umong1WVfL-fQNNZ9QEXvrHCJXCte1g_h_KA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/30/15 20:06), Andy Shevchenko wrote:
> 
> > +#include "i40e.h"
> 
> Why do you need this one exactly?

I needed it to find pf->pdev below.

> > +       struct device_node *dp = pci_device_to_OF_node(pf->pdev);

Without it, you will get:
              :
     CC [M]  drivers/net/ethernet/intel/i40e/i40e_common.o
   drivers/net/ethernet/intel/i40e/i40e_common.c: In function ?i40e_get_platform_mac_addr?:
   drivers/net/ethernet/intel/i40e/i40e_common.c:1021: error: dereferencing pointer to incomplete type


Unless you feel passionately about the \n nits, I'm going to pass on those. 
Thanks for reviewing.

--Sowmini
