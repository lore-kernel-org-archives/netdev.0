From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] drivers/net: Fix potential incorrect call for udelay()
Date: Mon, 23 Dec 2013 11:26:37 +0000
Message-ID: <20131223112637.46ae42e3@alan.etchedpixels.co.uk>
References: <1387791224-29320-1-git-send-email-huawei.libin@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <hsweeten@visionengravers.com>,
	<gregkh@linuxfoundation.org>, <tedheadster@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dingtianhong@huawei.com>
To: Libin <huawei.libin@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387791224-29320-1-git-send-email-huawei.libin@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Dec 2013 17:33:44 +0800
Libin <huawei.libin@huawei.com> wrote:

> From: Li Bin <huawei.libin@huawei.com>
> 
> The variable delay_time as a module parameter can be set a value
> exceeding the limit of the udelay function. This patch checks the
> delay_time value to select mdelay() or udelay().
> 
> Signed-off-by: Li Bin <huawei.libin@huawei.com>

Nobody should need to set a delay time that long, so this seems a rather
surplus check.

Alan
