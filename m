From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Fix 64bit bugs in dscc44.c
Date: Wed, 8 Oct 2003 17:55:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008155548.GB16937@wotan.suse.de>
References: <20031007175953.GA1802@averell> <20031008084205.5c81faac.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, ncorbic@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008084205.5c81faac.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 08, 2003 at 08:42:05AM -0700, David S. Miller wrote:
> On Tue, 7 Oct 2003 19:59:53 +0200
> Andi Kleen <ak@muc.de> wrote:
> 
> > ioremap_nocache returns unsigned long, not u32. This makes a difference
> > on 64bit hosts.
> 
> Incorrect, like ioremap() it returns "void *".

I knew someone would nit pick this ;-)

I agree it would have been better to write:
"ioremap and ioremap_nocache return pointers and that should 
be stored in a pointer variable. However when you really want 
to store them in a integer variable for unknown reasons always
use unsigned long, not u32 or int"

However that was just too long, so I didn't write it.

-Andi
