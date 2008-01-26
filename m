From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 12:40:36 +0100
Message-ID: <20080126114036.GA2624@ami.dom.local>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org> <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:53816 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbYAZLhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 06:37:39 -0500
Received: by ug-out-1314.google.com with SMTP id z38so662265ugc.16
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 03:37:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2008 at 02:16:01PM +0900, Joonwoo Park wrote:
> 2008/1/26, Andrew Morton <akpm@linux-foundation.org>:
> >
> > But whatever.   It used to work.  People's scripts will break.  Regression.
> >
> 
> Also I thought that 'replace with itself' should be error as like Jarek.
> But it used to work and patch made a regression, it's my bad :(

Actually, I don't think 'replace with itself' should be an error. I've
only meant that lack of this possibility shouldn't be necessarily seen
as error - there could be arguments for both sides.

IMHO, there should be simply analyzed pros and cons of doing it in
this particular place, so: if there is any gain in doing this, and if
possible complications or problems with performance, security etc.
don't prevail such a gain.

And I don't think a regression argument should be valid at all if
there are removed any unlogical, error-prone or otherwise problematic
options (I don't know if this is such case), even if they are not
obvious bugs - especially if it's still possible to do the same
'proper' way.

Regards,
Jarek P.
