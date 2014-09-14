From: sundeep subbaraya <sundeep.lkml@gmail.com>
Subject: Re: [PATCH] net: axienet: remove unnecessary ether_setup after alloc_etherdev
Date: Sun, 14 Sep 2014 14:00:36 +0530
Message-ID: <CALHRZuqGNAo7DLwGx1CYhcEF0rVurgGU3TyWq1fN4Oqp3k9Mtg@mail.gmail.com>
References: <78ce1faf-0bf8-41bb-a30d-cecd11d82d94@BY2FFO11FD033.protection.gbl>
	<20140912.181605.1878319812562851527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michal Simek <michals@xilinx.com>, svemula@xilinx.com,
	anirudh@xilinx.com, Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140912.181605.1878319812562851527.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks David,

Sundeep.

On Sat, Sep 13, 2014 at 3:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>
> Date: Thu, 11 Sep 2014 14:53:33 +0530
>
>> calling ether_setup is redundant since alloc_etherdev calls
>> it.
>>
>> Signed-off-by: Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
>
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
