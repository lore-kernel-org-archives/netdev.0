From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet
	device polling
Date: Tue, 21 May 2013 19:15:15 +0100
Message-ID: <1369160115.2615.51.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<519B632F.7040202@mellanox.com> <519B68A4.3010406@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Andi Kleen <andi@firstfloor.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <519B68A4.3010406@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 15:29 +0300, Eliezer Tamir wrote:
> Many of the questions you asked are covered in our RFC cover letter, but 
> I will touch them briefly
> 
> On 21/05/2013 15:06, Alex Rosenbaum wrote:
> > 1. It seem this patch does not cover epoll/select and such IO muxing APIs?
> 
> We are thinking about how to implement epoll support as one of the next 
> steps.
>
> What benchmarks are you using to test poll/select/epoll?
[...]

I raised this issue back at Plumbers and I thought Jesse said poll() was
covered.  It's likely to be a bit of a toy without that.  Also, UDP?

Solarflare uses a wide range of benchmarks.  Of the publicly available
applications, I believe Ixia Chariot uses (or can use) epoll.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
