From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Configure ICMP error source address
Date: Fri, 8 Jan 2016 17:21:13 +0100
Message-ID: <568FE1F9.9020101@stressinduktion.org>
References: <568F8207.9040305@heinlein-support.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Robert Sander <r.sander@heinlein-support.de>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <568F8207.9040305@heinlein-support.de>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.01.2016 10:31, Robert Sander wrote:
> Is it a good idea to develop a kernel patch that makes it possible to
> select the first IPv4 address on dev lo with scope global as the source
> address for ICMP errors? Would that do any harm to the Internet at large?

I think the way to go is to have a ip rule option in which the admin can 
add routes which get consulted only by the icmp source address 
determination logic. I can assume that some other installations use 
other interface number logic or multiple public addresses. This kind of 
lookup seems to allow all possible lookup scenarios.

Thoughts?

Hannes

