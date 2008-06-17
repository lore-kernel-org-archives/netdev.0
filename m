From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 13:09:10 +0000
Message-ID: <20080617130910.GA4632@ff.dom.local>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net> <4857B30B.8020809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:62328 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbYFQNE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:04:56 -0400
Received: by wr-out-0506.google.com with SMTP id 69so3373464wri.5
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 06:04:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4857B30B.8020809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 02:50:19PM +0200, Patrick McHardy wrote:
...
> Thanks for testing. Unfortunately the module unload races look
> more complicated to fix and I'm busy with other things, so it
> would great if someone else could fix this.

Patrick, I wonder if simply adding an additional mutex e.g.
genl_lock_table() around all the rest (after your patch) genl_locks
could be enough until some major rework. This should prevent any
new races and there are no lockups, I guess?

Jarek P.
