From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11865] New: WOL for E100 Doesn't
	Work Anymore
Date: Mon, 27 Oct 2008 22:02:24 -0700
Message-ID: <20081027220224.6333b675.akpm@linux-foundation.org>
References: <bug-11865-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, rogerx@sdf.lonestar.org
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-11865-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 26 Oct 2008 21:56:35 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11865
> 
>            Summary: WOL for E100 Doesn't Work Anymore
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: rogerx@sdf.lonestar.org
> 
> 
> Latest working kernel version: 2.6.27

This should read 2.6.26.  It is a regression.

> Earliest failing kernel version: 2.6.27
> Distribution: Gentoo
> Hardware Environment: 2x750P3 1G RAM w/ 
> 
> 00:14.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100]
> (rev 08)
> 
> Problem Description:
> As of kernel version 2.6.27, WOL has stopped working.  The box no longer powers
> on after the magic packet has been sent.  Rebooting using kernel-2.6.26*, WOL
> *does* work!
> 
> Steps to reproduce:
> (Not needed.  Self Explanatory.)
> 
> 
> I noticed 3 lines of code in e100.c added/modified since 2.6.26*, however, I
> reversed 2 lines of code to 2.6.26 and the other line was just added an
> additional pointer, for which I left alone.  Recompiled, rebooted and WOL still
> didn't work using 2.6.27.  I'm guessing, the source of this bug lies elsewhere.


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
