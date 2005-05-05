From: Patrick McHardy <kaber@trash.net>
Subject: Re: CONFIG_NETFILTER_DEBUG spew
Date: Fri, 06 May 2005 00:36:35 +0200
Message-ID: <427A9FF3.7060408@trash.net>
References: <20050501032809.3d0b4cda.akpm@osdl.org>
	<20050501111507.GA2133@gondor.apana.org.au>
	<4274F2ED.9080404@trash.net>
	<20050505111457.GS30482@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050505111457.GS30482@sunbeam.de.gnumonks.org>
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

Harald Welte wrote:
> On Sun, May 01, 2005 at 05:17:01PM +0200, Patrick McHardy wrote:
> 
>>You're right. I'm tempted to remove the entire nf_debug stuff,
>>as far as I know it has never found a real bug. But for now
>>I've only fixed the warning.
> 
> 
> yes, I second that change.  At the same time, we should get rid of all
> the lockhelp.h stuff that makes the netfilter code use non-standard lock
> primitives.

I've removed nf_debug. As for lockhelp.h, I'm still undecided whether
I should try to make rwlock debugging a feature of standard rwlocks
or else what to do with all the rwlock assertions.

Regards
Patrick
