From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cipso: cipso_v4_optptr enter infinite loop
Date: Tue, 01 Aug 2017 15:31:58 -0700 (PDT)
Message-ID: <20170801.153158.1079818266452638846.davem@davemloft.net>
References: <1501471381-12808-1-git-send-email-yujuan.qi@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, casey@schaufler-ca.com, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        ryder.lee@mediatek.com
To: yujuan.qi@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501471381-12808-1-git-send-email-yujuan.qi@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yujuan Qi <yujuan.qi@mediatek.com>
Date: Mon, 31 Jul 2017 11:23:01 +0800

> From: "yujuan.qi" <yujuan.qi@mediatek.com>
> 
> in for(),if((optlen > 0) && (optptr[1] == 0)), enter infinite loop.
> 
> Test: receive a packet which the ip length > 20 and the first byte of ip option is 0, produce this issue
> 
> Signed-off-by: yujuan.qi <yujuan.qi@mediatek.com>

Applied, thanks.
