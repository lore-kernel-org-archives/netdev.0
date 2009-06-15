From: Pavel Roskin <proski@gnu.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
 window
Date: Mon, 15 Jun 2009 16:31:23 -0400
Message-ID: <1245097883.10970.5.camel@mj>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	greg@kroah.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tshibata@ab.jp.nec.com
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:35209 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbZFOUbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 16:31:23 -0400
In-Reply-To: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-15 at 16:12 -0400, Luis R. Rodriguez wrote:
>  
> +Stable kernel releases
> +----------------------
> +
> +Stable kernels are released when they are ready. This means there is no
> +strict guidelines for sticking to specific dates for a kernel release.

there are no strict guidelines

> +After a maintainer has sent his pull request to Linus during the merge
> +window no further new development will be accepted for that tree and
> +as such it marks the closure of development for that subsystem for that
> +kernel cycle. Developers wishing to target deadlines should simply work
> +on their development without regards or consideration for inclusion to
> +a specific kernel release. Once development is done it should simply be
> +posted. If you insist on targetting a kernel release for deadlines you can

targeting

> +try to be aware of the current rc cycle development and how soon it seems
> +the next stable kernel relase will be made. When Linus notes the last rc

release

> +cycle released may be the last -- that is a good sign you should already
> +have all your development done and merged in the respective development
> +tree. If your code is not ready and merged into the respective maintainers
> +tree prior to the announced last potential rc kernel release chances are
> +you missed getting your code in for the next kernel merge window.
> +Excemptions here are new drivers, covered below.

Exemptions

> +rc-series rules
> +---------------
> +
> +Rules on what kind of patches are accepted after the merge window closes.
> +These are patches targetted for the kernel rc-series of a kernel prior

targeted

> +to its release.
> +
> + - it must fix a reported regression
> + - if must fix a reported security hole
> + - if must fix a reported oops/kernel hang
> +
> +This means any small-non-fix code changes, although they mix fix an issue,

might fix

> +will not be accepted. If the patch in question is for a driver that has been
> +around for more than a kernel release, then "small fixes" really can't be
> +worth all that much. And "small fixes" may be small and "obvious" they
> +definitely can regress.
> +
> +rc-series new driver excemption rule

exemption

> +------------------------------------
> +
> +The very first release a new driver (or filesystem) is special. New drivers
> +are accepted during the rc series. Patches for the same driver then are
> +also accepted uring the same rc series of a kernel as well as fixes as it

during

> +cannot regress as no previous kernels exists with it.
> +
> +Once drivers are upstream for one kernel release (say on 2.6.29) the target
> +*goal* after the merge window of the next kernel (respectively this would be
> +the 2.6.30 rc-series) is to address address regressions. Kernel oops/hangs

s/address address/address/

> +and security issues are obviously accepted but the point is these should have
> +also been caught earlier as a general development goal. The rc-series focus
> +should really be to address regressions.
> +
> +Stable kernel rules
> +-------------------
> +
>  Rules on what kind of patches are accepted, and which ones are not, into the
>  "-stable" tree:

Sorry, I'm in pedantic mood today.
 
-- 
Regards,
Pavel Roskin
