From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: Nested VLAN causes recursive locking error
Date: Mon, 31 Dec 2007 22:59:32 +0100
Message-ID: <20071231215932.GA10359@ami.dom.local>
References: <20071220135253.GA10932@ff.dom.local> <477904F1.6090403@trash.net> <20071231174555.GA3097@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:48310 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbXLaV5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 16:57:32 -0500
Received: by ug-out-1314.google.com with SMTP id z38so2336185ugc.16
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 13:57:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071231174555.GA3097@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 06:45:55PM +0100, Jarek Poplawski wrote:
> On Mon, Dec 31, 2007 at 04:04:17PM +0100, Patrick McHardy wrote:
...
> > That will increment the subclass globally, but it should actually just
> > use real_dev->subclass + 1. [...]
...
> to two subclasses - any nested vlan gets second. Otherwise, it seems
> there is some place needed to store these subclasses or use some
> unofficial checks on lockdep's structures?

...It seems there is simply needed additional macro in lockdep's API
to retrieve a subclass number from a lock! It would be at least
'strange' to have to save this doubly.

Jarek P.
