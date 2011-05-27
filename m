From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [Bugme-new] [Bug 36012] New: Kernel oops in __pskb_pull_tail
Date: Sat, 28 May 2011 00:30:30 +0200
Message-ID: <20110527223030.GA5081@uio.no>
References: <bug-36012-10286@https.bugzilla.kernel.org/>
 <20110527151715.a9888b74.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, e1000-devel@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:56841 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab1E0Wad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 18:30:33 -0400
Content-Disposition: inline
In-Reply-To: <20110527151715.a9888b74.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2011 at 03:17:15PM -0700, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

Just for reference; this happens to me every time I file a bug. Should I just
send it right to netdev@ the next time?

> Steinar's kernel went splat.  e1000 might be implicated.  It's a
> 2.6.38->2.6.39 regression.

af_packet might also be implicated (it shows up there in the background).
There's always a tcpdump running in the background (for
http://tcpmeasure.sesse.net/), which might be why I see this and nobody else
seems to have done yet.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
