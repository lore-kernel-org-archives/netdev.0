From: Glauber Costa <glommer@parallels.com>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Sat, 28 Jan 2012 01:28:35 +0400
Message-ID: <4F231703.4040803@parallels.com>
References: <20120127142246.GA22318@elte.hu> <4F22B634.2020007@parallels.com> <4F22D05A.8030604@parallels.com> <20120127.162823.1960229872591588915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <mingo@elte.hu>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120127.162823.1960229872591588915.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2012 01:28 AM, David Miller wrote:
> From: Glauber Costa<glommer@parallels.com>
> Date: Fri, 27 Jan 2012 20:27:06 +0400
>
>> +extern void init_tcp_mem(struct net *net);
>
> Please name this "tcp_init_mem" or similar, keeping all TCP functions
> globally exported with a "tcp_*" prefix.

Ok, will do.
