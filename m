From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] small skbuff.[ch] tweaks
Date: Tue, 2 Sep 2003 02:49:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902094942.GB53570@gaz.sfgoth.com>
References: <20030902081625.GA52298@gaz.sfgoth.com> <20030902105833.04778449.ak@suse.de> <20030902091059.GA53570@gaz.sfgoth.com> <20030902090423.GD3889@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030902090423.GD3889@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> > > Both unlikely(!ptr) and likely(ptr) are not needed because gcc assumes this
> > > by default
> > 
> > Is there any disadvantage to stating it explicitly?
> 
> It makes the code much uglier.

Well I guess it's a matter of taste then.  Personally I like unlikely()/
likely() a lot, even from just a readability standpoint.  I think it provides
a nice hint to the structure of code while reading it ("ok, we're just
handling an error case here, the meat of the code is below")  If anything they
help comment the code.

I certainly think they're preferable to "this is an unlikely error condition but
we shouldn't mark it as such because of some gcc trivia lets us save a few
characters of typing"

However if the consensus is that those unlikely()'s should be removed I'll be
happy to spin a new patch with those removed.

-Mitch
