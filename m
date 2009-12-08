From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: linux-next: net/kbuild trees build failure
Date: Tue, 8 Dec 2009 06:38:19 +0100
Message-ID: <20091208053819.GA4604@merkur.ravnborg.org>
References: <20091207200317.57820f0a.sfr@canb.auug.org.au> <20091207114158.GA2428@merkur.ravnborg.org> <4B1CF39A.5050806@suse.cz> <20091207160903.GB18939@tuxdriver.com> <1260209537.4653.778.camel@rc-desk> <4B1D76B1.6070601@suse.cz> <20091207222853.GE18939@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Marek <mmarek@suse.cz>,
	reinette chatre <reinette.chatre@intel.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091207222853.GE18939@tuxdriver.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2009 at 05:28:53PM -0500, John W. Linville wrote:
> On Mon, Dec 07, 2009 at 10:42:09PM +0100, Michal Marek wrote:
> > reinette chatre napsal(a):
> 
> > > Right - could we please use the solution that works at compile time? I
> > > used UTS_RELEASE after learning about its use in init/version.c, would
> > > that not make it an approved solution?
> > 
> > It seems there is some misunderstanding.
> 
> Alright, if Stephen's fix is acceptable then your suggestion is fine.
> Sam seemed to suggest that Stephen's fix was a stop-gap.

The need to use utsrelease seems very prominent in external drivers.
But a quick grep turned up only a single staging driver in-tree that
include utsrelease.
So whatever problem this driver solves using utsrelease it is not shared
with the rest of the in-tree drivers.

So no - it is not a stop-gap. It is more a "is it really needed?".

	Sam
