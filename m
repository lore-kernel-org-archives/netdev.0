From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Regression tracking
Date: Mon, 23 Jan 2012 01:52:25 +0100
Message-ID: <201201230152.25575.rjw@sisk.pl>
References: <201201222031.51116.maciej.rutecki@gmail.com> <201201222052.02135.maciej.rutecki@gmail.com> <20120122.150707.1411449164435920150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: maciej.rutecki@gmail.com, davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:45361 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540Ab2AWBHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 20:07:49 -0500
In-Reply-To: <20120122.150707.1411449164435920150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, January 22, 2012, David Miller wrote:
> From: Maciej Rutecki <maciej.rutecki@gmail.com>
> Date: Sun, 22 Jan 2012 20:52:02 +0100
> 
> > OK. But tracking regressions in two (or more) places is nonsense. And this 
> > puts into question all of my current work, such as how to analyze 
> > (automatically) the progress of the whole kernel and its quality per each -rc. 
> > Problem to discussion, but if everyone will do as you wish, it will all work 
> > went to waste.
> 
> If someone else wants to maintain the state of bugs on some web
> site and click buttons all day long, that is their perogative.
> 
> But it's not something I'm going to do.
> 
> You can't force people to use tools, and frankly that's the end of
> this conversation as far as I'm concerned.

Well, people who are tracking regressions need to keep the record of
what's been reported etc. somewhere and we use the Bugzilla for this
purpose (basically, as a database).  I, personally, have never been
expecting developers to follow the entries put in there by us, unless
they want to, but then we'd like the _reporters_ to update the status
(resolved/closed) which saves us quite some time (e.g. if someone
closes a bug entry created for a regression reported by him, we don't
need to dig through the git history and mailing lists archives or ask
developers whether or not the given bug has been fixed).

I hope that clarifies things.

Thanks,
Rafael
