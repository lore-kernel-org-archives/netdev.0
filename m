From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: compat support for sock_fprog
Date: Thu, 09 Jun 2016 23:41:19 -0700 (PDT)
Message-ID: <20160609.234119.2132907033141598314.davem@davemloft.net>
References: <1465315594-84301-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, deller@gmx.de,
	willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbcFJGlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:41:20 -0400
In-Reply-To: <1465315594-84301-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue,  7 Jun 2016 12:06:34 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Socket option PACKET_FANOUT_DATA takes a struct sock_fprog as argument
> if PACKET_FANOUT has mode PACKET_FANOUT_CBPF. This structure contains
> a pointer into user memory. If userland is 32-bit and kernel is 64-bit
> the two disagree about the layout of struct sock_fprog.
> 
> Add compat setsockopt support to convert a 32-bit compat_sock_fprog to
> a 64-bit sock_fprog. This is analogous to compat_sock_fprog support for
> SO_REUSEPORT added in commit 1957598840f4 ("soreuseport: add compat
> case for setsockopt SO_ATTACH_REUSEPORT_CBPF").
> 
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
