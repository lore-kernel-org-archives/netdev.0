From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] checkpatch: net and drivers/net: Warn on missing blank
 line after variable declaration
Date: Thu, 6 Mar 2014 15:55:17 -0800
Message-ID: <20140306155517.0b3976316b0335d16ab25e38@linux-foundation.org>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <20140306.142919.763823800315842610.davem@davemloft.net>
 <1394148520.16156.8.camel@joe-AO722>
 <20140306153530.bd61c160ba6f7872d6967b2e@linux-foundation.org>
 <1394149350.16156.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394149350.16156.13.camel@joe-AO722>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, 06 Mar 2014 15:42:30 -0800 Joe Perches <joe@perches.com> wrote:

> On Thu, 2014-03-06 at 15:35 -0800, Andrew Morton wrote:
> > On Thu, 06 Mar 2014 15:28:40 -0800 Joe Perches <joe@perches.com> wrote:
> > > Networking prefers this style, so warn when it's not used.
> > > void foo(int bar)
> > > {
> > > 	int baz;
> > > 
> > > 	code...
> > > }
> > > 
> > > not
> > > 
> > > void foo(int bar)
> > > {
> > > 	int baz;
> > > 	code...
> > > }
> > > 
> > > There are a limited number of false positives when using
> > > macros to declare variables like:
> > > 
> > > WARNING: networking uses a blank line after declarations
> > > #330: FILE: net/ipv4/inet_hashtables.c:330:
> > > +	int dif = sk->sk_bound_dev_if;
> > > +	INET_ADDR_COOKIE(acookie, saddr, daddr)
> > 
> > um wait wut wot.
> > 
> > *All* kernel code uses blank line between end-of-locals and
> > start-of-code.  Or if it doesn't it should, thwap.
> > Why are we special-casing net/?
> 
> It's easy enough to remove the path test, but it's
> not in CodingStyle and David seems to be the one
> that makes the effort to correct people about it.
> 
> I don't care one way or another.
> 
> I'm just trying to get fewer rejections for people
> that use checkpatch.

mutter.

OK, let's do this for now.  Could you please cook up a followon patch
which makes this kernel-wide?  I'll play with that for a while then I'll
decide how much I feel like irritating people.
