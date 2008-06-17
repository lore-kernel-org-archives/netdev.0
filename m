From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 15:08:25 +0200
Message-ID: <20080617130825.GD20815@postel.suug.ch>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net> <4857B30B.8020809@trash.net> <20080617130910.GA4632@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33372 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755727AbYFQNIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 09:08:06 -0400
Content-Disposition: inline
In-Reply-To: <20080617130910.GA4632@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jarek Poplawski <jarkao2@gmail.com> 2008-06-17 13:09
> On Tue, Jun 17, 2008 at 02:50:19PM +0200, Patrick McHardy wrote:
> ...
> > Thanks for testing. Unfortunately the module unload races look
> > more complicated to fix and I'm busy with other things, so it
> > would great if someone else could fix this.
> 
> Patrick, I wonder if simply adding an additional mutex e.g.
> genl_lock_table() around all the rest (after your patch) genl_locks
> could be enough until some major rework. This should prevent any
> new races and there are no lockups, I guess?

It would be wise to redo the locking alltogether while we're fixing
this. Decouple message serialization from register/unregister
operations would be a nice thing f.e.

I'll have a look if none beats me to it.
