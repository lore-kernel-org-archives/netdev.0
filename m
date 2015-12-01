From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Tue, 01 Dec 2015 14:30:47 -0500 (EST)
Message-ID: <20151201.143047.82022857078130793.davem@davemloft.net>
References: <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
	<1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, p.fedin@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Date: Tue, 1 Dec 2015 22:00:49 +0530

> Increasing descriptor ring size will lead to more memory allocation.
> And what you are seeing is a memory alloc failure and doesn't seem
> to be due to this driver change.  I mean it looks like the behavior
> will be same for other drivers as well.

The driver should successfully recover from out of memory situations
and not stop RX/TX completely.

There might be some other problem with your driver causing this.

Don't put this off as not "related" to your patch, it is as this
introduces the behavior for this user, and you should fix it before
expecting me to apply this patch series.
