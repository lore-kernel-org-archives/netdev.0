From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch v2] netpoll: warn when there are spaces in parameters
Date: Tue, 23 Mar 2010 09:44:56 +0800
Message-ID: <4BA81D18.40509@redhat.com>
References: <20100322090341.5289.10770.sendpatchset@localhost.localdomain> <1269296535.3552.10.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	elendil@planet.nl, David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269296535.3552.10.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Mon, 2010-03-22 at 04:59 -0400, Amerigo Wang wrote:
>> +			printk(KERN_INFO "%s: warning: whitespace"
>> +					"is not allowed\n", np->name);
> 
> Is it a warning or is it info? If it's a warning, then we probably need
> to add "netpoll" or whatever to the message so that people who've got a
> warning-level threshold will know what it's about.
> 

If you mean KERN_INFO, yeah, I want to keep it in the same level
as other messages around.

Also, I already put "np->name" which will be "netconsole" when
we use netconsole.

Thanks.
