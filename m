From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 28 Sep 2005 12:34:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0509281232420.4655@filer.marasystems.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509221503.21650.ak@suse.de>
	<20050923170911.GN731@sunbeam.de.gnumonks.org>
	<200509271823.19365.ak@suse.de>
	<Pine.LNX.4.61.0509280219110.25500@filer.marasystems.com>
	<20050928083240.GP4168@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050928083240.GP4168@sunbeam.de.gnumonks.org>
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

On Wed, 28 Sep 2005, Harald Welte wrote:

> Just imagine all those poor sysadmins who know nothing about current
> kernel development, and who upgrade their kernel because their
> distributor provides a new one - suddenly their accounting (which might
> be relevant for their business) doesn't work anymore :(

You seriously expect anyone is using the counters on the policy rule in 
otherwise completely empty rulesets? These counters is also available 
elsewhere (route and interface statistics) and more intuitively so.

> yes, even though we could make the ip_nat / iptable_nat split (that is
> introduced in 2.6.14) in a way that would make ip_nat.ko register those
> hooks that are implicitly needed, and iptable_nat only the user-visible
> chain-related hooks.

Which adds additional overhead, so this approach is a bit 
counter-productive I would say.

Regards
Henrik
