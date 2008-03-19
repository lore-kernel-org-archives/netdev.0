From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Wed, 19 Mar 2008 20:17:25 +0100
Message-ID: <20080319191724.GA2756@ami.dom.local>
References: <20080318015006.3f0efb8e.akpm@linux-foundation.org> <20080318210542.GA2764@ami.dom.local> <20080318144742.83f544f9.akpm@linux-foundation.org> <20080318224729.GA2760@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:30491 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757969AbYCSTmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:42:37 -0400
Received: by fg-out-1718.google.com with SMTP id l27so524774fgb.17
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 12:42:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080318224729.GA2760@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2008 at 11:47:29PM +0100, Jarek Poplawski wrote:
...
> Anyway... My first tests seemed to hang the box with syslog only. Now
> I can't repeat it neither with syslog nor netconsole... So, this patch
> is a bad hit or it's really about timing.

I've just repeated this this test with syslog only. After letting it
go for ~5 min. I couldn't break it with any keys for at least next 10
min., and I turned the power down. Then the same but with this sched.c
patch reverted: ^C worked after a few seconds. It looks like time
can really matter here.

So, maybe it's again something accidental, I don't have another box
around to stay idle while repeting this test, but it seems this could
be not the best way to compare anything with 2.6.24 or older.

Regards,
Jarek P.
