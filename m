From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] constify atm pci_device_id.
Date: Sun, 16 Jul 2017 16:38:28 -0700 (PDT)
Message-ID: <20170716.163828.1992619563611727642.davem@davemloft.net>
References: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-atm-general@lists.sourceforge.net
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Sun, 16 Jul 2017 15:02:28 +0530

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.

Series applied to net-next, thanks.
