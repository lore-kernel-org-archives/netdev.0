From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 15:32:32 +0100
Message-ID: <20080126143232.GD2624@ami.dom.local>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org> <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com> <20080126114036.GA2624@ami.dom.local> <20080126141010.GC2624@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:57586 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbYAZO2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 09:28:20 -0500
Received: by ug-out-1314.google.com with SMTP id z38so672858ugc.16
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 06:28:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080126141010.GC2624@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2008 at 03:10:10PM +0100, Jarek Poplawski wrote:
...
> [...] so old thing is always supposed to be
> destroyed (of course it's a matter of implementation or conditions in
> which moment this destruction takes place).
> 
> So, 'replace with itself' is simply ambiguous: we can always delete the
> object first, to prepare the place for replacement, and find there is
> nothing to do after this - and it's probably not what somebody wanted.

As a matter of fact, the moment of destruction doesn't even matter:
assuming the replaced thing is destroyed in all 'common' cases, doing
this at the end isn't probably wanted as well - and skipping this
action makes an exception - what IMHO proves the concept is at least
inconsistent.

Jarek P.
