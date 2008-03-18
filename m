From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: netconsole still hangs
Date: Tue, 18 Mar 2008 08:04:39 +0000
Message-ID: <20080318080439.GA3965@ff.dom.local>
References: <20080312235205.dcec2d35.akpm@linux-foundation.org> <20080314234749.GA10606@ami.dom.local> <20080317161222.0fb9dfc9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:45672 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbYCRIC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 04:02:57 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2190722fgb.17
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 01:02:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080317161222.0fb9dfc9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2008 at 04:12:22PM -0700, Andrew Morton wrote:
...
> I retested.  This patch doesn't appear to make anything worse, but the hang
> is still there.  

Yes, but since this doesn't look like something very common, and we
don't even know if this OOPS and the hangs are the same bug, there is
needed more information e.g.:

- is it reproducible with e1000E only and no wlan?
- is there a possibility to check this with some other card
  (even wlan while e1000E is off)?
- could you add .config to the bugzilla report:
  http://bugzilla.kernel.org/show_bug.cgi?id=10238
- is it acceptable to send you some patches for debugging this?

Regards,
Jarek P.
