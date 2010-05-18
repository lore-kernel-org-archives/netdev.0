From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARCNET: Limit com20020 PCI ID matches for SOHARD cards
Date: Mon, 17 May 2010 23:12:56 -0700 (PDT)
Message-ID: <20100517.231256.146340344.davem@davemloft.net>
References: <20100512004852.GA25845@amos.infernal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: aeb@debian.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100512004852.GA25845@amos.infernal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Bombe <aeb@debian.org>
Date: Wed, 12 May 2010 02:49:06 +0200

> The SH SOHARD ARCNET cards are implemented using generic PLX Technology
> PCI<->IOBus bridges. Subvendor and subdevice IDs were not specified,
> causing the driver to attach to any such bridge and likely crash the
> system by attempting to initialize an unrelated device.
> 
> Fix by specifying subvendor and subdevice according to the values found
> in the PCI-ID Repository at http://pci-ids.ucw.cz/ .
> 
> Cc: stable@kernel.org
> Signed-off-by: Andreas Bombe <aeb@debian.org>

Applied, thank you.
