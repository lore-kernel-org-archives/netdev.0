From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH] net: sched: document attach_default_qdiscs
Date: Tue, 15 Sep 2015 00:42:08 +0200
Message-ID: <20150914224208.GJ30501@orbit.nwl.cc>
References: <1442244690-6672-1-git-send-email-phil@nwl.cc>
 <CAHA+R7PATvda=EPof5mHY_CNH1OnkVnRytJPbJgZHtTkgMB9LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60414 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469AbbINWmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 18:42:10 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7PATvda=EPof5mHY_CNH1OnkVnRytJPbJgZHtTkgMB9LA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 03:07:42PM -0700, Cong Wang wrote:
> On Mon, Sep 14, 2015 at 8:31 AM, Phil Sutter <phil@nwl.cc> wrote:
> > The process of selecting an interface's default qdisc is not really
> > intuitive, at least because there are three different cases to consider.
> 
> It is a static function, not an API, so I don't think it is the right
> place to document.

So static functions should never be documented? I'm playing devil's
advocate, but still:

> Maybe update default_qdisc description in Documentation/sysctl/net.txt?

I don't think this is the right place for source code documentation. The
intended audience are users, and I wouldn't expect a developer to search
in there. On the other hand, that description would indeed benefit from
a review: Apart from omitting noqueue, it neither mentions leaf qdiscs.
I'll fix this.

Thanks, Phil
