From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: 2.6.7 patches
Date: Sun, 4 Jul 2004 11:13:10 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040704151310.GE14482@ruslug.rutgers.edu>
References: <5.1.0.14.2.20040702124232.00b0d1c0@pop.t-online.de>
	<20040704150616.GD14482@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <20040704150616.GD14482@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


Oh and PS, all this should be discussed on netdev, CC prism54-devel. I
forgot to include netdev in the thread in my reply.

	Luis

On Sun, Jul 04, 2004 at 11:06:16AM -0400, Luis R. Rodriguez wrote:
> On Fri, Jul 02, 2004 at 01:12:46PM +0200, Margit Schubert-While wrote:
> > Aurelien scribeth:
> > > I've checked the changes in CVS and I disagree with the patch #5 
> > (removing the writes to some pci registers).
> > > Those changes will have huge consequences on card/driver stability. It 
> > should have been debated here before.
> > > Moreover windows drivers do those writes, and adding them solved a lot 
> > of stability issues in prism54.
> > 
> > 1) Well, many months ago, it was talked about
> 
> I do not remember these register writes being disabled being discussed
> here. This needs further investigation. I believe more people are going
> to be affected by removing it than adding it, not sure though. We should
> figure out exactly what is meant by "legacy" devices and see if we can
> detect this on the code itself.
> 
> 	Luis
> 
> -- 
> GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
> _______________________________________________
> Prism54-devel mailing list
> Prism54-devel@prism54.org
> http://prism54.org/mailman/listinfo/prism54-devel

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
