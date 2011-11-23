From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netprio_cgroup: Fix build break
Date: Wed, 23 Nov 2011 09:22:09 -0500
Message-ID: <20111123142209.GC27968@hmsreliant.think-freely.org>
References: <1322051553-28987-1-git-send-email-nhorman@tuxdriver.com>
 <20111123131147.GA11508@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	john.r.fastabend@intel.com, robert.w.love@intel.com,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111123131147.GA11508@tugrik.mns.mnsspb.ru>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 05:11:47PM +0400, Kirill Smelkov wrote:
> On Wed, Nov 23, 2011 at 07:32:33AM -0500, Neil Horman wrote:
> > I broke the build with the addition of netprio_cgroups if CONFIG_CGROUPS=n.
> > This patch corrects it by moving the offending struct into an ifdef
> > CONFIG_CGROUPS block.  Also clean up a few needless defines and inline functions
> > that don't get called if CONFIG_CGROUPS isn't defined while Im at it.
> 
> Thanks Neil, now it compiles ok.
> 
Np, sorry for the trouble.  I should have double checked that make oldconfig did
what I assumed it did
Neil
