From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH] #1: cleanup, add reset debug message
Date: Tue, 10 Aug 2004 20:18:09 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040811001809.GF26262@ruslug.rutgers.edu>
References: <200408101823.15792.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200408101823.15792.vda@port.imtp.ilyichevsk.odessa.ua>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


Denis,

this one seems fine to me  although for netdev we'll need a patch
against linux kernel dirs (linux-2.6.8-rc4/drivers/net/prism54/) instead
of cvs tarball.

Jeff if you accept I'll apply to our CVS.

	Luis

On Tue, Aug 10, 2004 at 06:23:15PM +0300, Denis Vlasenko wrote:
> Hi Luis,
> 
> This is a mostly trivial patch on top of today's prism54 CVS.
> 
> * Move assignment out of if()
> * Remove trailing space from printk
> * Eliminate not needed local 'u32 reg'
> * Add a comment about undoc bits
> * Add #define VEC_SIZE, use it as appropriate
> * Add a pair of printks to reset error code path (our current area of trouble)
> * Make printk text less confusing
> 
> Please apply.
> --
> vda



-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
