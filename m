From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Tue, 17 Oct 2006 18:26:04 +0200
Message-ID: <200610171826.05028.dada1@cosmosbay.com>
References: <11587449471424@2ka.mipt.ru> <200610171732.28640.dada1@cosmosbay.com> <20061017160155.GA18522@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Johann Borck <johann.borck@densedata.com>,
	Ulrich Drepper <drepper@redhat.com>,
	Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:35803 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751284AbWJQQ0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 12:26:05 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061017160155.GA18522@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 October 2006 18:01, Evgeniy Polyakov wrote:

> Ok, there is one apologist for mmap buffer implementation, who forced me
> to create first implementation, which was dropped due to absense of
> remote mental reading abilities.
> Ulrich, does above approach sound good for you?
> I actually do not want to reimplement something, that will be
> pointed to with words 'no matter what you say, it is broken and I do not
> want it' again :).

In my humble opinion, you should first write a 'real application', to show how 
the mmap buffer and kevent syscalls would be used (fast path and 
slow/recovery paths). I am sure it would be easier for everybody to agree on 
the API *before* you start coding a *lot* of hard (kernel) stuff : It would 
certainly save your mental CPU cycles (and ours too :) )

This 'real application' could be  the event loop of a simple HTTP server, or a 
basic 'echo all' server. Adding the bits about timers events and signals 
should be done too.

Eric
