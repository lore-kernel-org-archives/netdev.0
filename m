From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/8] Make some network-related proc files use
 seq_list_xxx helpers
Date: Tue, 10 Jul 2007 22:42:37 -0700 (PDT)
Message-ID: <20070710.224237.58786266.davem@davemloft.net>
References: <20070709.131523.93383253.davem@davemloft.net>
	<200707110005.l6B05EWo024030@toshiba.co.jp>
	<20070710172052.22c0510a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, netdev@vger.kernel.org,
	xemul@sw.ru, xemul@openvz.org, torvalds@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754575AbXGKFmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 01:42:15 -0400
In-Reply-To: <20070710172052.22c0510a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 10 Jul 2007 17:20:52 -0700

> On Wed, 11 Jul 2007 09:05:13 +0900 (JST)
> Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp> wrote:
> 
> > 
> > I've met compile error on net-2.6.23 tree.
> > 
> > net/built-in.o: In function `proto_seq_next':
> > sock.c:(.text+0x3008): undefined reference to `seq_list_next'
> > net/built-in.o: In function `proto_seq_start':
> > sock.c:(.text+0x3079): undefined reference to `seq_list_start_head'
> > make: *** [.tmp_vmlinux1] Error 1
> > 
> 
> crap, that's my fault, sorry.  Sending David patches which depend on things
> which are in -mm.
> 
> Let me send
> make-common-helpers-for-seq_files-that-work-with-list_head-s.patch
> Linuswards and it all should come good.

I've rebased my tree at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

now that this has been sorted out.
