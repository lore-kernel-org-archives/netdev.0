From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH net-next] be2net: be_hwmon_show_temp() can be static
Date: Fri, 15 May 2015 13:19:21 +0800
Message-ID: <20150515051921.GA3787@wfg-t540p.sh.intel.com>
References: <201505150315.NZBccr7Q%fengguang.wu@intel.com>
 <20150514190234.GA103883@snb>
 <20150514.173946.1264501038106193211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ying.xue@windriver.com, kbuild-all@01.org,
	sathya.perla@avagotech.com, ajit.khaparde@avagotech.com,
	padmanabh.ratnakar@avagotech.com,
	sriharsha.basavapatna@avagotech.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150514.173946.1264501038106193211.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 14, 2015 at 05:39:46PM -0400, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Fri, 15 May 2015 03:02:35 +0800
> 
> > 
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> > ---
> >  be_main.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> > index dc7c0fd..76d491f 100644
> > --- a/drivers/net/ethernet/emulex/benet/be_main.c
> > +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> > @@ -5612,7 +5612,7 @@ static void be_remove(struct pci_dev *pdev)
> >  	free_netdev(adapter->netdev);
> >  }
> >  
> > -ssize_t be_hwmon_show_temp(struct device *dev,
> > +static ssize_t be_hwmon_show_temp(struct device *dev,
> >  			   struct device_attribute *dev_attr,
> >  			   char *buf)
> 
> If you adjust the column of the openning parenthesis of the
> function, you have to reindent the subsequent lines so that they
> start precisely at the very next column.
> 
> You must use the appropriate number of TAB and SPACE characters
> necessary to do so.

OK. We'll improve the script to adjust indent accordingly.

Thanks,
Fengguang
