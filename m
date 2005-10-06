From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 6 Oct 2005 19:59:56 +0200
Message-ID: <20051006175956.GI6642@verdi.suse.de>
References: <432EF0C5.5090908@cosmosbay.com> <200509281037.03185.ak@suse.de>
	<4342B575.9090709@trash.net> <200510051853.32196.ak@suse.de>
	<20051007023801.GA5953@rama>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>, Andi Kleen <ak@suse.de>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <20051007023801.GA5953@rama>
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

On Fri, Oct 07, 2005 at 04:38:02AM +0200, Harald Welte wrote:
> On Wed, Oct 05, 2005 at 06:53:31PM +0200, Andi Kleen wrote:
> > On Tuesday 04 October 2005 19:01, Patrick McHardy wrote:
> > > Andi Kleen wrote:
> > > > In a sense it's even getting worse: For example us losing the CONFIG
> > > > option to disable local conntrack (Patrick has disabled it some time ago
> > > > without even a comment why he did it) has a really bad impact in some
> > > > cases.
> > >
> > > It was necessary to correctly handle locally generated ICMP errors.
> > 
> > Well you most likely wrecked local performance then when it's enabled.
> 
> so you would favour a system that incorrectly deals with ICMP errors but
> has higher performance?

I would favour a system where development doesn't lose sight of performance.
Perhaps there would be other ways to fix this problem without impacting
performance unduly? Can you describe it in detail? 

-Andi
