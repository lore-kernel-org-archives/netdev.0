From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Tue, 18 Mar 2008 23:47:29 +0100
Message-ID: <20080318224729.GA2760@ami.dom.local>
References: <20080318015006.3f0efb8e.akpm@linux-foundation.org> <20080318210542.GA2764@ami.dom.local> <20080318144742.83f544f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:53098 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939430AbYCSV6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:58:35 -0400
Received: by fk-out-0910.google.com with SMTP id 19so753142fkr.5
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 14:58:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080318144742.83f544f9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2008 at 02:47:42PM -0700, Andrew Morton wrote:
> On Tue, 18 Mar 2008 22:05:42 +0100
> Jarek Poplawski <jarkao2@gmail.com> wrote:
...
> > IMHO, after the below patch to sched.c you can't compare netconsole to
> > 2.6.24 with this sysrq-trigger test; any bugs found with this could be
...
> hm.
...
> So right now it's cannot-reproduce.  I'll try things on the other machine
> this evening.
> 
> I dunno why the sched.c change causes your sysrq-T operation to fail.  Can
> you provide more details please?

...hmm...
Doesn't sysrq-t trigger this sched.c function?

Anyway... My first tests seemed to hang the box with syslog only. Now
I can't repeat it neither with syslog nor netconsole... So, this patch
is a bad hit or it's really about timing.

Jarek P.
