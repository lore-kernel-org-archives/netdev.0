From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] small skbuff.[ch] tweaks
Date: Tue, 2 Sep 2003 11:04:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902090423.GD3889@wotan.suse.de>
References: <20030902081625.GA52298@gaz.sfgoth.com> <20030902105833.04778449.ak@suse.de> <20030902091059.GA53570@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
Content-Disposition: inline
In-Reply-To: <20030902091059.GA53570@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 02, 2003 at 02:10:59AM -0700, Mitchell Blank Jr wrote:
> Andi Kleen wrote:
> > Both unlikely(!ptr) and likely(ptr) are not needed because gcc assumes this
> > by default
> 
> Is there any disadvantage to stating it explicitly?

It makes the code much uglier.

-Andi
