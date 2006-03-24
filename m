From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] ip_conntrack_helper_h323.c: EXPORT_SYMBOL'ed
	functions shouldn't be static
Date: Fri, 24 Mar 2006 01:29:07 +0100
Message-ID: <20060324002907.GQ22727@stusta.de>
References: <20060324000801.GM22727@stusta.de>
	<20060323.161314.59991770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	zhaojignmin@hotmail.com, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060323.161314.59991770.davem@davemloft.net>
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

On Thu, Mar 23, 2006 at 04:13:14PM -0800, David S. Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Fri, 24 Mar 2006 01:08:01 +0100
> 
> > EXPORT_SYMBOL'ed functions shouldn't be static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Fixed in Linus's tree as of yesterday.

Sorry for missing this, this must have been after Andrew pulled Linus' 
tree for creating 2.6.16-mm1 (which is where I was looking at).

> I actually have a patch from Patrick McHardy that will make
> this kind of error a build time failure instead of silently
> working in the modular case.  I just need to test it out
> a bit before pushing.

Yes, it would be nice if it would also fail in CONFIG_MODULES=y builds.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
