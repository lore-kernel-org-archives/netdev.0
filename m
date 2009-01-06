From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [GIT]: Networking
Date: Tue, 6 Jan 2009 06:51:44 +0100
Message-ID: <20090106055144.GA11695@uranus.ravnborg.org>
References: <alpine.LFD.2.00.0901051839330.3057@localhost.localdomain> <20090105.201530.195720489.davem@davemloft.net> <alpine.LFD.2.00.0901052029220.3057@localhost.localdomain> <20090105.204934.65827705.davem@davemloft.net> <3f9a31f40901052114t68cac881md439bf24b602f269@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:57267 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbZAFFuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 00:50:13 -0500
Content-Disposition: inline
In-Reply-To: <3f9a31f40901052114t68cac881md439bf24b602f269@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 10:44:11AM +0530, Jaswinder Singh Rajput wrote:
> On Tue, Jan 6, 2009 at 10:19 AM, David Miller <davem@davemloft.net> wrote:
> >
> > I had 4 firmware patches to apply, each one had to add entries
> > to the same file.
> >
> > The first patch had to be skipped.
> >
> 
> In firmware we maintain WHENCE, so every time we add new firmware we
> also update WHENCE.
> 
> We are facing problems while we prepare patch for firmware as we add
> new stuff at the end.
> As per David Woodhouse suggestion, I arranged WHENCE to alphabetical
> order by driver name to avoid conflicts.
> 
> I also send patch on 21 Dec 2008 with ack of David Woodhouse to linus
> and waiting from his side.
> 
> [PATCH] firmware: Arrange WHENCE in alphabetical order to avoid conflicts
> 
> I think this will resolve very soon, once we update WHENCE in
> alphabetical order, If you better suggestions, please let me know.

We should avoid a central file and push this information
out to the Kconfig files that are at the driver site.

Then we can postprocess autoconf.h to get the filenames etc.

And IMO it is wrong to stroe the firmware files far away
from the driver where they belong.

Sorting WHENCE is a good approach under the current ways
of doing it. But the current ways of doing it looks plain wrong to me.

	Sam
