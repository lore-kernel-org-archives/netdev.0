From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/8] Make some network-related proc files use
 seq_list_xxx helpers
Date: Tue, 10 Jul 2007 17:20:52 -0700
Message-ID: <20070710172052.22c0510a.akpm@linux-foundation.org>
References: <200707091851.l69IpAma001726@imap1.linux-foundation.org>
	<20070709.131523.93383253.davem@davemloft.net>
	<200707110005.l6B05EWo024030@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, xemul@sw.ru,
	xemul@openvz.org, Linus Torvalds <torvalds@linux-foundation.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56695 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752607AbXGKAW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:22:26 -0400
In-Reply-To: <200707110005.l6B05EWo024030@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 09:05:13 +0900 (JST)
Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp> wrote:

> 
> I've met compile error on net-2.6.23 tree.
> 
> net/built-in.o: In function `proto_seq_next':
> sock.c:(.text+0x3008): undefined reference to `seq_list_next'
> net/built-in.o: In function `proto_seq_start':
> sock.c:(.text+0x3079): undefined reference to `seq_list_start_head'
> make: *** [.tmp_vmlinux1] Error 1
> 

crap, that's my fault, sorry.  Sending David patches which depend on things
which are in -mm.

Let me send
make-common-helpers-for-seq_files-that-work-with-list_head-s.patch
Linuswards and it all should come good.

