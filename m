From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sun, 27 Jan 2008 12:14:15 +0100
Message-ID: <20080127111415.GA14306@ami.dom.local>
References: <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org> <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com> <20080126114036.GA2624@ami.dom.local> <20080126141010.GC2624@ami.dom.local> <jeve5gd5mz.fsf@sykes.suse.de> <20080126151934.GA2969@ami.dom.local> <20080127011126.GA3408@ami.dom.local> <Pine.LNX.4.58.0801271127490.8409@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schwab <schwab@suse.de>,
	Joonwoo Park <joonwpark81@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:26828 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbYA0LKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 06:10:08 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1297019fga.17
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2008 03:10:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0801271127490.8409@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 27, 2008 at 11:49:06AM +0200, Julian Anastasov wrote:
...
> 	No, simply the last change in 2.6.24 is wrong to assume 
> duplication is evident in fib_info reference counter. And such check
> is only on ip route replace/change. I'm appending brief FIB information
> for your reference:

Thank you very much! I've just planned to look more at this code today,
and maybe try to find how your new patch copes with this problem, so
this description should be really helpful!

But, since we agree now it's a bug and regression in 2.6.24, it seems
this should be fixed as soon as possible, and since your patch isn't
probably tested enough for stable, it looks like safe bet to revert
Joonwoo's patch, at least until this all is more verified.

Regards,
Jarek P.
