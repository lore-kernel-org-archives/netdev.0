From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Make xfrm subsystem optional
Date: Sat, 14 Jun 2003 11:36:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614093630.GB16993@wotan.suse.de>
References: <20030614091631.GA16993@wotan.suse.de> <20030614.022702.41637600.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030614.022702.41637600.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 14, 2003 at 02:27:02AM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: Sat, 14 Jun 2003 11:16:31 +0200
>    
>    This patches only compiles the xfrm subsystem in when any of the options
>    using it are selected. This shrinks the text segment on an amd64
>    kernel by ~32k, data by ~6k, bss by ~33k, overall ~72K memory saved.
> 
> I'm not going to apply this, sorry Andi.
> 
> I want the freedom to use the XFRM layer for generic things
> at some point.

But in 2.7 surely right? When what happens you can easily
make CONFIG_XFRM the default. This would give the 2.6 users
an useful option.

Also when you do use it generically you will hopefully
discard some old code (like the rt cache?) which may make
up for the additional bloat. But until that happens having
both even when not needed doesn't make too much sense.

> 
> How about working on making the xfrm layer more lean instead? :)

My last proposal for this (using hlists in the hash tables) was 
rejected, so I don't see much chance to do this.

-Andi
