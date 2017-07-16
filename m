From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] Constify isdn pci_device_id's.
Date: Sat, 15 Jul 2017 21:26:36 -0700 (PDT)
Message-ID: <20170715.212636.1472722201553868071.davem@davemloft.net>
References: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, dhowells@redhat.com, johannes.berg@intel.com,
        mac@melware.de, baoyou.xie@linaro.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Sat, 15 Jul 2017 09:55:41 +0530

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.

Series applied, thanks.
