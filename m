From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH V1 net] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Thu, 10 Apr 2014 15:33:55 +0300
Message-ID: <20140410153355.0ca4348f@jpm-OptiPlex-GX620>
References: <1397121924-14813-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1397121924-14813-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Apr 2014 17:25:24 +0800
Wei Yang <weiyang@linux.vnet.ibm.com> wrote:

> pci_match_id() just match the static pci_device_id, which may return
> NULL if someone binds the driver to a device manually using
> /sys/bus/pci/drivers/.../new_id.
> 
> This patch wrap up a helper function __mlx4_remove_one() which does
> the tear down function but preserve the drv_data. Functions like
> mlx4_pci_err_detected() and mlx4_restart_one() will call this one
> with out releasing drvdata.
> 
> Fixes: 97a5221 "net/mlx4_core: pass pci_device_id.driver_data to
> __mlx4_init_one during reset".
> 
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> CC: Jack Morgenstein <jackm@dev.mellanox.co.il>
> CC: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

  Acked-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
