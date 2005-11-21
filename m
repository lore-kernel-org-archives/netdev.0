From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 17:52:56 +0100
Message-ID: <4381FB68.2090103@trash.net>
References: <20051120163135.16666.76993.sendpatchset@localhost.localdomain>	<200511210442.jAL4gPoO001846@toshiba.co.jp>	<43816EB4.4080205@trash.net>
	<20051120.230034.105307423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	yasuyuki.kozakai@toshiba.co.jp
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20051120.230034.105307423.davem@davemloft.net>
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
> I've read over Patrick's two most recent postings of these patches
> and I think they are generally sane and I cannot find any holes in
> them.  Herbert brought up the legitimate concern about defragmentation,
> but I think that's a detail and does not take away from the structural
> soundness of Patrick's approach.

I think we implicitly agreed on moving the POST_ROUTING hook before
fragmentation and change the user-visible behaviour of the mangle
POSTROUTING chain. At least neither Harald not Rusty objected to
the patch :)
