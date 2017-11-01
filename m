From: David Miller <davem@davemloft.net>
Subject: Re: net: lapbether: fix double free
Date: Wed, 01 Nov 2017 12:11:44 +0900 (KST)
Message-ID: <20171101.121144.2041853344891602326.davem@davemloft.net>
References: <1509285442-24312-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509285442-24312-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>
Date: Sun, 29 Oct 2017 21:57:22 +0800

> The function netdev_priv() returns the private data of the device. The
> memory to store the private data is allocated in alloc_netdev() and is
> released in netdev_free(). Calling kfree() on the return value of
> netdev_priv() after netdev_free() results in a double free bug.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
