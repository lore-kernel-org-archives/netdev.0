From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: fix issue of io access mode for AR8152 v2.1
Date: Fri, 20 Jul 2012 11:23:13 -0700 (PDT)
Message-ID: <20120720.112313.1153363658413977902.davem@davemloft.net>
References: <1342753318-4507-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342753318-4507-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <cjren@qca.qualcomm.com>
Date: Fri, 20 Jul 2012 11:01:58 +0800

> When io access mode is enabled by BOOTROM or BIOS for AR8152 v2.1,
> the register can't be read/write by memory access mode.
> Clearing Bit 8  of Register 0x21c could fixed the issue.
> 
> Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: xiong <xiong@qca.qualcomm.com>

Applied.
