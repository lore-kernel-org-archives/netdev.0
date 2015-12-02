From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 12:31:03 -0500 (EST)
Message-ID: <20151202.123103.122030174756190808.davem@davemloft.net>
References: <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
	<20151201.143047.82022857078130793.davem@davemloft.net>
	<CA+sq2CduMnsh_R9zTRMjWT=F5=9U3si-5nO6-gFvGCO9czkDdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, p.fedin@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+sq2CduMnsh_R9zTRMjWT=F5=9U3si-5nO6-gFvGCO9czkDdA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Date: Wed, 2 Dec 2015 11:18:43 +0530

>>The driver should successfully recover from out of memory situations
>> and not stop RX/TX completely.
> This memory allocation is while interface bringup/initialization and not during
> packet I/O.
> 
>>Don't put this off as not "related" to your patch, it is as this
>>introduces the behavior for this user, and you should fix it before
>>expecting me to apply this patch series.
> I would disagree on this, as this patch hasn't introduced any failure here,
> if this user has connected any device which asks for a bit large amount
> of coherent memory then i am sure he will see the same issue.

It's not the memory allocation that's the problem.

It's the the device completely dies and does not recover even when
memory does become available later.

That is a hard regression which this change introduces.
