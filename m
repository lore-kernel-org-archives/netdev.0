From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Fri, 30 Oct 2015 07:26:37 -0400
Message-ID: <20151030112637.GB9312@oracle.com>
References: <20151029233430.GB11420@oracle.com>
 <CAHp75VcmgsAjgqt6+JVMB6uvbbJamoBnLyEU=YNCRp=s2fAW1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	martin.petersen@oracle.com
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHp75VcmgsAjgqt6+JVMB6uvbbJamoBnLyEU=YNCRp=s2fAW1A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/30/15 02:14), Andy Shevchenko wrote:
> 
> Does the following has no stubs?
> 
> > +       struct i40e_pf *pf = hw->back;
> > +       struct device_node *dp = pci_device_to_OF_node(pf->pdev);
> > +       const unsigned char *addr;
> > +
> > +       addr = of_get_mac_address(dp);
> 
> ^^^

I was not able to find any.
I'm fixing up the rest and respinning V2 as a separate thread.

Thanks
--Sowmini
