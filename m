From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: fix possible NULL deref in dnet_select_source()
Date: Tue, 08 Apr 2014 12:37:50 -0400 (EDT)
Message-ID: <20140408.123750.693837509861075227.davem@davemloft.net>
References: <1396821554.12330.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140407.151854.411047851818388937.davem@davemloft.net>
	<1396932704.16584.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396932704.16584.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Apr 2014 21:51:44 -0700

> On Mon, 2014-04-07 at 15:18 -0400, David Miller wrote:
> 
>> And in the loopback case, it is the decnet stack's responsibility to
>> make sure ->dn_ptr is setup properly, else it should fail the module
>> load and stack initialization.
>> can fix this properly.
> 
> This was based on Sasha report and my limited time.
> It seems you have more time than me to spend on decnet !

Understood, I'll take a deeper look into this.
