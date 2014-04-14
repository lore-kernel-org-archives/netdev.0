From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 14:23:24 -0700
Message-ID: <1397510604.4222.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397499566.4222.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.144843.488522666550066271.davem@davemloft.net>
	 <1397502396.4222.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.152225.1983723140136958968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414.152225.1983723140136958968.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-14 at 15:22 -0400, David Miller wrote:


> 
> You still need to make similar transformation to ip_local_out() as mentioned
> above.

I was trying to cook a not too invasive patch.

Changing ip_local_out() means changing dst_output() / nf_hook()  and
hundred of call sites.

Unless I misunderstood you ?
