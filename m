From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Mon, 7 May 2007 16:48:37 +0200
Message-ID: <20070507144837.GA30865@slug>
References: <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug> <20070504154009.GE8751@csclub.uwaterloo.ca> <20070504174456.GC8753@csclub.uwaterloo.ca> <20070504175017.GD8753@csclub.uwaterloo.ca> <20070504182433.GA11595@verizon.net> <20070504190236.GE8753@csclub.uwaterloo.ca> <20070507140807.GF8753@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <pcnet32@verizon.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:29590 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426AbXEGOt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 10:49:57 -0400
Received: by an-out-0708.google.com with SMTP id d18so147615and
        for <netdev@vger.kernel.org>; Mon, 07 May 2007 07:49:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070507140807.GF8753@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 10:08:07AM -0400, Lennart Sorensen wrote:
> On Fri, May 04, 2007 at 03:02:36PM -0400, Lennart Sorensen wrote:
> > Well I don't know, but something is going wrong and causing the soft
> > lock up.  I must admit I am surprised if an interrupt can occour while
> > handling an interrupt, but then again maybe that is supposed to be
> > allowed.
> 
> I tried building a kernel where the only change was enabling the spin
> lock debugging.  It doesn't fail, while without spin lock debugging it
> seemed to fail very frequently.  Darn!  I hate when debugging makes hides
> the problem.
Can you try running on another Geode LX system, just to rule out a
hardware problem on you board?

Regards,
Frederik
