From: Thomas Graf <tgraf@suug.ch>
Subject: Re: linux-next: build failure after merge of the final tree
 (netnext-tree related)
Date: Mon, 29 Jul 2013 09:13:50 +0100
Message-ID: <20130729081350.GA28340@casper.infradead.org>
References: <20130729162544.574e4d7ffccf0f6bff5ba4c4@canb.auug.org.au>
 <20130729.004746.91827990830866654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130729.004746.91827990830866654.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/29/13 at 12:47am, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 29 Jul 2013 16:25:44 +1000
> 
> > After merging the final tree, today's linux-next build (powerpc
> > allyesconfig) failed like this:
> 
> Sorry about that.
> 
> > I added this commit:
> 
> Applied, thanks Stephen.

Thanks for the fix-up Stephen, the include is needed on archs that
don't provide an optimized csum_ipv6_magic().
