From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Mon, 7 May 2007 10:08:07 -0400
Message-ID: <20070507140807.GF8753@csclub.uwaterloo.ca>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug> <20070504154009.GE8751@csclub.uwaterloo.ca> <20070504174456.GC8753@csclub.uwaterloo.ca> <20070504175017.GD8753@csclub.uwaterloo.ca> <20070504182433.GA11595@verizon.net> <20070504190236.GE8753@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frederik Deweerdt <deweerdt@free.fr>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:42343 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934087AbXEGOII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 10:08:08 -0400
Content-Disposition: inline
In-Reply-To: <20070504190236.GE8753@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 03:02:36PM -0400, Lennart Sorensen wrote:
> Well I don't know, but something is going wrong and causing the soft
> lock up.  I must admit I am surprised if an interrupt can occour while
> handling an interrupt, but then again maybe that is supposed to be
> allowed.

I tried building a kernel where the only change was enabling the spin
lock debugging.  It doesn't fail, while without spin lock debugging it
seemed to fail very frequently.  Darn!  I hate when debugging makes hides
the problem.

--
Len Sorensen
