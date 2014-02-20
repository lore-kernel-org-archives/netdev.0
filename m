From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Thu, 20 Feb 2014 10:13:11 +0000
Message-ID: <20140220101311.GA24574@zion.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com>
 <1392743214.23084.38.camel@kazak.uk.xensource.com>
 <5303C44D.4070500@citrix.com>
 <1392804319.23084.109.camel@kazak.uk.xensource.com>
 <53050BF5.1060009@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53050BF5.1060009@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 19, 2014 at 07:54:29PM +0000, Zoltan Kiss wrote:
> On 19/02/14 10:05, Ian Campbell wrote:
> >On Tue, 2014-02-18 at 20:36 +0000, Zoltan Kiss wrote:
> >>On 18/02/14 17:06, Ian Campbell wrote:
> >>>On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
> >>>>This patch contains the new definitions necessary for grant mapping.
> >>>
> >>>Is this just adding a bunch of (currently) unused functions? That's a
> >>>slightly odd way to structure a series. They don't seem to be "generic
> >>>helpers" or anything so it would be more normal to introduce these as
> >>>they get used -- it's a bit hard to review them out of context.
> >>I've created two patches because they are quite huge even now,
> >>separately. Together they would be a ~500 line change. That was the best
> >>I could figure out keeping in mind that bisect should work. But as I
> >>wrote in the first email, I welcome other suggestions. If you and Wei
> >>prefer this two patch in one big one, I merge them in the next version.
> >
> >I suppose it is hard to split a change like this up in a sensible way,
> >but it is rather hard to review something which is split in two parts
> >sensibly.
> >
> >If the combined patch too large to fit on the lists?
> Well, it's ca. 30 kb, ~500 lines changed. I guess it's possible.
> It's up to you and Wei, if you would like them to be merged, I can
> do that.
> 

As I said before, my bottom line is "don't break bisection". Do whatever
you want to. :-)

Wei.
