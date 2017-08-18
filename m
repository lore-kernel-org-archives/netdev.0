From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V5 net-next 01/21] net-next/hinic: Initialize hw
 interface
Date: Thu, 17 Aug 2017 17:45:40 -0700
Message-ID: <20170817174540.46986450@xeon-e3>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
        <544e2ccb65ea083d9b736df6ea0bdd59353da815.1502970631.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <544e2ccb65ea083d9b736df6ea0bdd59353da815.1502970631.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Aug 2017 19:52:42 +0800
Aviad Krawczyk <aviad.krawczyk@huawei.com> wrote:

> +	nic_dev = (struct hinic_dev *)netdev_priv(netdev);

Sinc netdev_priv() returns void *, a cast is not necessary here.
