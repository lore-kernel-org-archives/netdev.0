From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: corretly check failed allocation
Date: Thu, 15 Oct 2015 23:31:57 -0700 (PDT)
Message-ID: <20151015.233157.923931397415718098.davem@davemloft.net>
References: <1444926249-29033-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, maorg@mellanox.com, ogerlitz@mellanox.com,
	jackm@dev.mellanox.co.il, yishaih@mellanox.com,
	viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444926249-29033-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Thu, 15 Oct 2015 12:24:09 -0400

> When allocation fails, mlx4_alloc_cmd_mailbox returns -ENOMEM.
> Since there is no case that mlx4_alloc_cmd_mailbox returns NULL,
> it needs to be checked by IS_ERR, not IS_ERR_OR_NULL
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied to net-next, thanks.
