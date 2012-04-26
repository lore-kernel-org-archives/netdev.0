From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] atl1c: update hardware settings - v3
Date: Thu, 26 Apr 2012 05:05:42 -0400 (EDT)
Message-ID: <20120426.050542.243663587525305831.davem@davemloft.net>
References: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiong <xiong@qca.qualcomm.com>
Date: Thu, 26 Apr 2012 14:27:08 +0800

> This update contains a serial of patches, most of them are hardware
> settings related. register definitions are refined (or removed if
> meaningless) for each patch.
> 
> This is the third serial patches, after reviewed/applied the fourth
> serial will be out.
> 
> The patches have addressed all sparse and checkpatch warnings.
> 
> Following NICs are tested:
> AR8131/AR8132/AR8151A/AR8152A/AR8152B
> Test item includes:
> build/install/uninstall/dhcp/ping/iperf/wol/reboot/etc.

I've applied patches #1 until #9, patch #10 needs to be done
differently.

The PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG bit should be set via a PCI
quirk entry in drivers/pci/quirks.c just as it is done for other
devices which have this problem.

Thank you.
