From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 net-next 01/21] net-next/hinic: Initialize hw
 interface
Date: Thu, 17 Aug 2017 22:03:43 -0700 (PDT)
Message-ID: <20170817.220343.905568389038615738.davem@davemloft.net>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
        <544e2ccb65ea083d9b736df6ea0bdd59353da815.1502970631.git.aviad.krawczyk@huawei.com>
        <20170817174205.6a1b12b6@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aviad.krawczyk@huawei.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bc.y@huawei.com, victor.gissin@huawei.com,
        zhaochen6@huawei.com, tony.qu@huawei.com
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817174205.6a1b12b6@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 17 Aug 2017 17:42:05 -0700

> Please drop these functions, they do nothing and are not used
> as stubs in any operations table.

It might have been helpful to scan the entire series to understand
why it looks this way.

He's building the driver up, one piece at a time, filling in the full
implementation as is possible as more and more infrastructure is added.

So some functions start empty when a method is needed to be filled in,
and then gradually obtains more and more content throughout the
series.

And this is a fine way to add a huge new driver (although not my
personal preference).
