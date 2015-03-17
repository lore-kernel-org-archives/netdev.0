From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/6] inet: tcp listener refactoring, part 11
Date: Tue, 17 Mar 2015 15:18:44 -0400 (EDT)
Message-ID: <20150317.151844.1980938482640561349.davem@redhat.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463AbbCQTSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 15:18:50 -0400
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 16 Mar 2015 21:06:14 -0700

> Before inserting request sockets into general (ehash) table,
> we need to prepare netfilter to cope with them, as they are
> not full sockets.
> 
> I'll later change xt_socket to get full support, including for
> request sockets (NEW_SYN_RECV) 
> 
> Save 8 bytes in inet_request_sock on 64bit arches. We'll soon add
> a pointer to the listener socket.
> 
> I included two TCP changes in this patch series.

This looks fine, just continuing the sk_fullsock() transformations from
the previous serious pretty much.

Applied, th anks.
