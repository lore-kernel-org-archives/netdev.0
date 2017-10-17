From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v2 09/15] ACPI: configfs: make config_item_type const
Date: Tue, 17 Oct 2017 02:10:57 +0200
Message-ID: <3026721.pYNdH8r6C9@aspire.rjw.lan>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1508167134-6243-10-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: julia.lawall@lip6.fr, lenb@kernel.org,
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
        cluster-devel@redhat.com, ocfs2-devel
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cloudserver094114.home.net.pl ([79.96.170.134]:43669 "EHLO
        cloudserver094114.home.net.pl" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933105AbdJQAUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 20:20:34 -0400
In-Reply-To: <1508167134-6243-10-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, October 16, 2017 5:18:48 PM CEST Bhumika Goyal wrote:
> Make these structures const as they are either passed to the functions
> having the argument as const or stored as a reference in the "ci_type"
> const field of a config_item structure.
> 
> Done using Coccienlle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
> * Changes in v2- Combine all the followup patches and the constification
> patches into a series.
> 
>  drivers/acpi/acpi_configfs.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_configfs.c b/drivers/acpi/acpi_configfs.c
> index 853bc7f..b588503 100644
> --- a/drivers/acpi/acpi_configfs.c
> +++ b/drivers/acpi/acpi_configfs.c
> @@ -204,7 +204,7 @@ struct configfs_attribute *acpi_table_attrs[] = {
>  	NULL,
>  };
>  
> -static struct config_item_type acpi_table_type = {
> +static const struct config_item_type acpi_table_type = {
>  	.ct_owner = THIS_MODULE,
>  	.ct_bin_attrs = acpi_table_bin_attrs,
>  	.ct_attrs = acpi_table_attrs,
> @@ -237,12 +237,12 @@ struct configfs_group_operations acpi_table_group_ops = {
>  	.drop_item = acpi_table_drop_item,
>  };
>  
> -static struct config_item_type acpi_tables_type = {
> +static const struct config_item_type acpi_tables_type = {
>  	.ct_owner = THIS_MODULE,
>  	.ct_group_ops = &acpi_table_group_ops,
>  };
>  
> -static struct config_item_type acpi_root_group_type = {
> +static const struct config_item_type acpi_root_group_type = {
>  	.ct_owner = THIS_MODULE,
>  };
>  
> 

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
