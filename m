From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH v2 06/15] PCI: endpoint: make config_item_type const
Date: Mon, 16 Oct 2017 13:24:37 -0500
Message-ID: <20171016182437.GG25517@bhelgaas-glaptop.roam.corp.google.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
 <1508167134-6243-7-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
        cluster-devel@redh
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1508167134-6243-7-git-send-email-bhumirks@gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 05:18:45PM +0200, Bhumika Goyal wrote:
> Make config_item_type structures const as they are either passed to a
> function having the argument as const or stored in the const "ci_type"
> field of a config_item structure.
> 
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

Please apply this along with the rest of the series, since it depends
on an earlier patch in the series.

> ---
> * Changes in v2- Combine all the followup patches and the constification
> patches into a series.
> 
>  drivers/pci/endpoint/pci-ep-cfs.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/pci/endpoint/pci-ep-cfs.c b/drivers/pci/endpoint/pci-ep-cfs.c
> index 424fdd6..4f74386 100644
> --- a/drivers/pci/endpoint/pci-ep-cfs.c
> +++ b/drivers/pci/endpoint/pci-ep-cfs.c
> @@ -150,7 +150,7 @@ static void pci_epc_epf_unlink(struct config_item *epc_item,
>  	.drop_link	= pci_epc_epf_unlink,
>  };
>  
> -static struct config_item_type pci_epc_type = {
> +static const struct config_item_type pci_epc_type = {
>  	.ct_item_ops	= &pci_epc_item_ops,
>  	.ct_attrs	= pci_epc_attrs,
>  	.ct_owner	= THIS_MODULE,
> @@ -361,7 +361,7 @@ static void pci_epf_release(struct config_item *item)
>  	.release		= pci_epf_release,
>  };
>  
> -static struct config_item_type pci_epf_type = {
> +static const struct config_item_type pci_epf_type = {
>  	.ct_item_ops	= &pci_epf_ops,
>  	.ct_attrs	= pci_epf_attrs,
>  	.ct_owner	= THIS_MODULE,
> @@ -400,7 +400,7 @@ static void pci_epf_drop(struct config_group *group, struct config_item *item)
>  	.drop_item      = &pci_epf_drop,
>  };
>  
> -static struct config_item_type pci_epf_group_type = {
> +static const struct config_item_type pci_epf_group_type = {
>  	.ct_group_ops	= &pci_epf_group_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -428,15 +428,15 @@ void pci_ep_cfs_remove_epf_group(struct config_group *group)
>  }
>  EXPORT_SYMBOL(pci_ep_cfs_remove_epf_group);
>  
> -static struct config_item_type pci_functions_type = {
> +static const struct config_item_type pci_functions_type = {
>  	.ct_owner	= THIS_MODULE,
>  };
>  
> -static struct config_item_type pci_controllers_type = {
> +static const struct config_item_type pci_controllers_type = {
>  	.ct_owner	= THIS_MODULE,
>  };
>  
> -static struct config_item_type pci_ep_type = {
> +static const struct config_item_type pci_ep_type = {
>  	.ct_owner	= THIS_MODULE,
>  };
>  
> -- 
> 1.9.1
> 
