From: Adrian Bunk <bunk@stusta.de>
Subject: Re: 2.6 patch] ip_conntrack_helper_h323.c: make
	get_h245_addr()static
Date: Fri, 24 Mar 2006 08:55:11 +0100
Message-ID: <20060324075511.GV22727@stusta.de>
References: <20060324000916.GN22727@stusta.de>
	<BAY109-DAV122F44146DB217251703AEB3DF0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Jing Min Zhao <zhaojignmin@hotmail.com>, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Jing Min Zhao <zhaojingmin@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY109-DAV122F44146DB217251703AEB3DF0@phx.gbl>
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

On Thu, Mar 23, 2006 at 09:37:15PM -0500, Jing Min Zhao wrote:
> 
> I'd like to keep it global. In the future we may need it.

The point is:
There have been many occasions where people have said "I will need this 
soon" in many different places in the kernel, and one year later it was 
still unused.

If it will be needed at some point in the future, reverting my patch
will be trivial.

> Thanks
> 
> Jing Min Zhao

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
