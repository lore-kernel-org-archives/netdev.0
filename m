From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 14:03:20 +0200
Message-ID: <20050812120319.GK8974@wotan.suse.de>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<20050811.154204.102613246.davem@davemloft.net>
	<p73u0hv2xkv.fsf@verdi.suse.de> <42FC8EBC.1070505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42FC8EBC.1070505@trash.net>
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

> Unfortunately one of the iptables structures which is needed to get the
> ruleset in the kernel (ipt_replace) is differently sized when compiled
> for 32/64 bit. IIRC it doesn't work at all currently.

Yes that's the old bug and cannot be fixed without breaking compatibility. 

But we hope that ctnetlink will not repeat that mistake. That is why I'm suggesting
to use aligned_u64 in all new interfaces

-Andi
