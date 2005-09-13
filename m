From: "David S. Miller" <davem@davemloft.net>
Subject: Re: masquerading failure for at least icmp and tcp+sack on amd64
Date: Tue, 13 Sep 2005 13:59:54 -0700 (PDT)
Message-ID: <20050913.135954.111731835.davem@davemloft.net>
References: <20050911131943.GC9865@schmorp.de> <43243AB9.9000705@trash.net>
	<20050913110902.0ad58b90@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net, schmorp@schmorp.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: shemminger@osdl.org
In-Reply-To: <20050913110902.0ad58b90@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 13 Sep 2005 11:09:02 -0700

> Also, on the input path for TCP and UDP, the code does not
> depend on the hardware being correct, and if the checksum
> is incorrect, it just prints a warning and does a software
> checksum before deciding to drop.
> Perhaps netfilter code needs to handle that case?

I personally think netfilter should do so.
