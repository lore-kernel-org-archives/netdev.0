From: Andrew Morton <akpm@osdl.org>
Subject: Re: Problem with 3c59x, WOL and Intel 440LX/EX or 430TX
Date: Wed, 11 Feb 2004 23:46:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211234622.4a5bce7a.akpm@osdl.org>
References: <20040211170727.GC18571@smtp.west.cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, chris@k-rad.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Tom Rini <trini@kernel.crashing.org>
In-Reply-To: <20040211170727.GC18571@smtp.west.cox.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tom Rini <trini@kernel.crashing.org> wrote:
>
> Hello.  I believe I have tracked down a problem with the WOL support in
>  the 3c59x driver (2.6 varriant only right now).  The problem has been
>  seen I belive by a few people:
>  (my own reports)
>  http://marc.theaimsgroup.com/?l=linux-kernel&m=106297008218993&w=2
>  http://lkml.org/lkml/2003/9/2/167

I have a suspicion that this may be a bug in the driver's PM handling but I
don't really have time to reacquaint myself with the driver.  Or it could
be a BIOS bug.

I've put the enable_wol module parameter back.
