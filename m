From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 20:56:49 +0100
Message-ID: <1197316609.6399.124.camel@lov.site>
References: <11972872493977@2ka.mipt.ru> <11972872501664@2ka.mipt.ru>
	 <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com>
	 <20071210125839.GA16789@2ka.mipt.ru> <1197297108.6399.91.camel@lov.site>
	 <20071210145055.GB7184@2ka.mipt.ru> <1197313348.6399.106.camel@lov.site>
	 <20071210193304.GA24737@2ka.mipt.ru> <1197315895.6399.121.camel@lov.site>
	 <20071210195145.GA29132@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:64635 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbXLJT4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 14:56:41 -0500
In-Reply-To: <20071210195145.GA29132@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-12-10 at 22:51 +0300, Evgeniy Polyakov wrote:
> On Mon, Dec 10, 2007 at 08:44:55PM +0100, Kay Sievers (kay.sievers@vrfy.org) wrote:
> > > > > Actually not - I have to set reference counter to something other than 1
> > > > > or +/- 1, and thus will have to call kref_get() in a loop, which is a
> > > > > very ugly step. Is there kref_set() or somethinglike that? At least not
> > > > > in 2.6.22 what I'm using for now.
> > > > 
> > > > Yeah, a loop would look pretty ugly. How about just adding kref_set(),
> > > > if you need it.
> > > 
> > > Well, then it distributed storage will not be able to build as
> > > standalone module, and kref_set() itself will not be accepted as a single 
> > > patch, since there are no in-kernel users :)
> > > It is easily doable though.
> > 
> > Most rules have exceptions. :) Send a patch, so we can see how it looks
> > like.
> 
> It looks really non-trivial :)

Yeah, it does. :)
We miss an EXPORT_SYMBOL(), right?

Kay

