From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [RFC] random SYN drops causing connect() delays
Date: Wed, 28 Apr 2010 00:44:43 -0400
Message-ID: <20100428044443.GL19763@bombadil.infradead.org>
References: <20100412080633.GA27418@bombadil.infradead.org> <20100412083903.GA19763@bombadil.infradead.org> <20100427.185602.221594952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56175 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab0D1Eoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 00:44:44 -0400
Content-Disposition: inline
In-Reply-To: <20100427.185602.221594952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 06:56:02PM -0700, David Miller wrote:
> I can't reproduce on my system even with sched_child_runs_first set to '1'.
> 
> Are you running identd or something like that which intercepts the connections
> to port 22 before 'sshd' actually gets it?

No, sshd is listening on the port directly.

I am having more difficulties to reproduce the issue with the latest git tree. It
still happens but I sometimes have to run the test several times to get a single
delayed connection attempt.
