From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH, RESEND] Add MWI workaround for Tulip DC21143
Date: Tue, 7 Mar 2006 03:58:24 +0000
Message-ID: <20060307035824.GA24018@linux-mips.org>
References: <20060129230816.GD4094@colonel-panic.org> <20060218220851.GA1601@colonel-panic.org> <20060306225131.GA23327@unjust.cyrius.com> <20060306231530.GB16082@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060306231530.GB16082@electric-eye.fr.zoreil.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 07, 2006 at 12:15:30AM +0100, Francois Romieu wrote:

> [...]
> > Does anyone have comments regarding this patch?  I received
> > confirmation from a number of Debian users that this patch
> > significantly improves the lockup situation on Cobalt, so
> > it would be nice if it could go in.
> 
> I'll queue it with the pending de2104x fix(es ?) during my next
> upkeep.

I'm just not convinced of having such a workaround as a build option.
The average person building a a kernel will probably not know if the
option needs to be enabled or not.

  Ralf
