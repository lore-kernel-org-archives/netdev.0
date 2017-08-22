From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: amd: constify zorro_device_id
Date: Tue, 22 Aug 2017 14:35:58 -0700 (PDT)
Message-ID: <20170822.143558.1542799741189180105.davem@davemloft.net>
References: <1503425472-24469-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503425472-24469-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Tue, 22 Aug 2017 23:41:12 +0530

> zorro_device_id are not supposed to change at runtime. All functions
> working with zorro_device_id provided by <linux/zorro.h> work with
> const zorro_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
