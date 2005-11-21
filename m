From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Sun, 20 Nov 2005 23:00:34 -0800 (PST)
Message-ID: <20051120.230034.105307423.davem@davemloft.net>
References: <20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<200511210442.jAL4gPoO001846@toshiba.co.jp>
	<43816EB4.4080205@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	yasuyuki.kozakai@toshiba.co.jp
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43816EB4.4080205@trash.net>
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

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Nov 2005 07:52:36 +0100

> I don't see why it is confusing. Plain text packets are visible before
> encapsulation (and they have to be because we don't necessarily know
> if packets will be encapsulated at the time the hooks are called in
> case the policy lookup after NAT returns a policy), plain text packets
> are visible after decapsulation. With different hooks we can't have
> symetrical behaviour because of the case I mentioned above, and that
> would be confusing IMO.

I think this is a very important point.

I can see no serious argument against this behavior, especially for
output.  On input, there is an argument of paranoia about seeing
plaintext packets, but administrator could do this anyways with
tcpdump or custom kernel module if this system is the decapsulation
point.

I've read over Patrick's two most recent postings of these patches
and I think they are generally sane and I cannot find any holes in
them.  Herbert brought up the legitimate concern about defragmentation,
but I think that's a detail and does not take away from the structural
soundness of Patrick's approach.
