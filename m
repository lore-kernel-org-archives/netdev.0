From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 12:07:14 -0700
Message-ID: <20050422120714.35f56e76.davem@davemloft.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422183004.GC10598@muc.de>
	<1114196487.7978.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, gnb@sgi.com, akepner@sgi.com, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114196487.7978.65.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 15:01:27 -0400
jamal <hadi@cyberus.ca> wrote:

> Dont mean to make this into a meaningless debate - but have you thought
> of the fact maybe it could be a driver bug in case of NAPI?
> The e1000 NAPI had a serious bug since day one that was only recently
> fixed (I think Robert provided the fix - but the intel folks made the
> release).

True, but really Jamal I think a lot of this has to do with
not doing a small amount of hw coalescing even when doing NAPI.

Let's get people testing changes like that to see if it undoes
the bad cases.  I want to do something proactive with these
reports instead of just asking for more performance data like
a bunch of crazed lunatics :-)
