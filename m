From: Patrick McHardy <kaber@trash.net>
Subject: Re: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 14 Sep 2005 03:13:39 +0200
Message-ID: <43277943.8050700@trash.net>
References: <20050911131943.GC9865@schmorp.de>	<43243AB9.9000705@trash.net>	<20050913110902.0ad58b90@localhost.localdomain>
	<20050913.135954.111731835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	schmorp@schmorp.de, shemminger@osdl.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050913.135954.111731835.davem@davemloft.net>
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

David S. Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 13 Sep 2005 11:09:02 -0700
> 
> 
>>Also, on the input path for TCP and UDP, the code does not
>>depend on the hardware being correct, and if the checksum
>>is incorrect, it just prints a warning and does a software
>>checksum before deciding to drop.
>>Perhaps netfilter code needs to handle that case?
> 
> I personally think netfilter should do so.

I agree. One thing I've planned for some silent moment is
to clean up the entire netfilter checksumming code (there's
lots of small duplicated chunks). Probably at least some
of it will also be applicable for the remaining stack.
