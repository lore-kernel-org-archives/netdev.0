From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl/fman: remove of_node
Date: Mon, 02 Oct 2017 16:04:45 -0700 (PDT)
Message-ID: <20171002.160445.737065995396076298.davem@davemloft.net>
References: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Mon, 2 Oct 2017 13:31:37 +0300

> The FMan MAC driver allocates a platform device for the Ethernet
> driver to probe on. Setting pdev->dev.of_node with the MAC node
> triggers the MAC driver probing of the new platform device. While
> this fails quickly and does not affect the functionality of the
> drivers, it is incorrect and must be removed. This was added to
> address a report that DSA code using of_find_net_device_by_node()
> is unable to use the DPAA interfaces. Error message seen before
> this fix:
> 
> fsl_mac dpaa-ethernet.0: __devm_request_mem_region(mac) failed
> fsl_mac: probe of dpaa-ethernet.0 failed with error -16
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>

Is the DSA issue no longer something we need to be concerned
about?  If not, why?  You have to explain this.
