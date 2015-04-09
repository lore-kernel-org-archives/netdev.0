From: Zefan Li <lizefan@huawei.com>
Subject: Re: Stable inclusion request: recvmsg/sendmsg userspace regression
 fix
Date: Thu, 9 Apr 2015 09:24:03 +0800
Message-ID: <5525D4B3.6070400@huawei.com>
References: <54CBA338.1000207@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ani Sinha <ani@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stable Tree <stable@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: Michal Marek <mmarek@suse.cz>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54CBA338.1000207@suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: Ben

On 2015/1/30 23:28, Michal Marek wrote:
> Hi,
> 
> please include
> 
> commit 6a2a2b3ae0759843b22c929881cc184b00cc63ff
> Author: Ani Sinha <ani@arista.com>
> Date:   Mon Sep 8 14:49:59 2014 -0700
> 
>     net:socket: set msg_namelen to 0 if msg_name is passed as NULL in
> msghdr struct from userland.
> 
> to 3.14.y and older trees, since it fixes a userspace regression caused
> by commit dbb490b9 ("net: socket: error on a negative msg_namelen"). The
> patch applies cleanly to all trees down to 2.6.32.y.
> 

Queued up for 3.4. Thansks!

It's still missing from 3.2.y, so cc Ben.
