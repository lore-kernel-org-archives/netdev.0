From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch v2] net: export TCP send buffer size via netlink
Date: Mon, 01 Feb 2010 18:21:39 +0800
Message-ID: <4B66AB33.60202@redhat.com>
References: <20100201092153.4194.91507.sendpatchset@localhost.localdomain>	<20100201.020055.57470143.davem@davemloft.net> <20100201.020622.91421099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100201.020622.91421099.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Before you spend the next couple hours trying to figure out what to
> do...
> 
> We already provide the information you're trying to export via
> linux/inet_diag.h:inet_diag_meminfo
> 
> I hope the light goes on now :-)
> 

Oh, I was just looking for a pointer.

Ok, ->idiag_wmem is gotten from sk->sk_wmem_queued, so ->sk_wmem_queued
is the TCP send buffer size that we want? I thought it is ->sk_sndbuf...

Thanks for your help!
