From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Replace driver's usage of hard-coded device IDs to
 #defines
Date: Wed, 24 May 2017 20:02:49 -0400 (EDT)
Message-ID: <20170524.200249.1492095559302424098.davem@davemloft.net>
References: <20170524224734.24221.33787.stgit@amt.stowe>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
        bhelgaas@google.com, saeedm@mellanox.com, noaos@mellanox.com,
        tariqt@mellanox.com
To: myron.stowe@redhat.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170524224734.24221.33787.stgit@amt.stowe>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Myron Stowe <myron.stowe@redhat.com>
Date: Wed, 24 May 2017 16:47:34 -0600

> Noa Osherovich introduced a series of new Mellanox device ID definitions to
> help differentiate specific controllers that needed INTx masking quirks [1].
> 
> Bjorn Helgaas followed on, using the device ID definitions Noa provided to
> replace hard-coded values within the mxl4 ID table [2].
>     
> This patch continues along similar lines, adding a few additional Mellanox
> device ID definitions and converting the net/mlx5e driver's mlx5 ID table to
> use the defines so tools like 'grep' and 'cscope' can be used to help
> identify relationships with other aspects (such as INTx masking).

If you're adding pci_ids.h defines, it's only valid to do so if you
actually use the defines in more than one location.

This patch series is not doing that.
