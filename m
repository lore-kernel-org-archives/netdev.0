From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf-next-2.6] netfilter: {ip,ip6,arp}_tables: dont block
 bottom half more than necessary
Date: Mon, 02 Aug 2010 16:54:08 +0200
Message-ID: <4C56DC10.9060301@trash.net>
References: <1279898595.2481.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279898595.2481.69.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 17:23, Eric Dumazet wrote:
> We currently disable BH for the whole duration of get_counters()
> 
> On machines with a lot of cpus and large tables, this might be too long.
> 
> We can disable preemption during the whole function, and disable BH only
> while fetching counters for the current cpu.
> 

Applied, thanks Eric.

