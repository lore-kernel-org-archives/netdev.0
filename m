From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Fix locking bug in lltx path
Date: Mon, 13 Sep 2004 21:26:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913192649.GA26975@wotan.suse.de>
References: <m3vfei9gzv.fsf@averell.firstfloor.org> <20040913121859.44fbf949.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com, arjanv@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040913121859.44fbf949.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 13, 2004 at 12:18:59PM -0700, David S. Miller wrote:
> On Mon, 13 Sep 2004 20:11:00 +0200
> Andi Kleen <ak@muc.de> wrote:
> 
> > Thanks to Arjan's spinlock debug kernel for finding it.
> > 
> > This fixes a silly missing spin lock in the relock path. For some 
> > reason it seems to still work when you don't have spinlock debugging
> > enabled.
> > 
> > Please apply.
> 
> Good catch, but I'll need to fix this up to use the new macros
> defined in linux/netdevice.h

Ok, do you want me to send a new patch with that? 

I don't think the new macros are in -bk* snapshots yet,
and getting it otherwise is difficult for me.

It's probably fastest if you just apply it by hand.

-Andi
