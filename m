From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: rcvbuf autotuning improvements
Date: Thu, 03 Oct 2013 06:13:35 -0700
Message-ID: <1380806015.19002.210.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380787003-20488-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Francesco Fusco <ffusco@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:57157 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167Ab3JCNNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 09:13:37 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so2453556pdj.21
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 06:13:36 -0700 (PDT)
In-Reply-To: <1380787003-20488-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 09:56 +0200, Daniel Borkmann wrote:

> We also renamed tcp_fixup_rcvbuf() to tcp_rcvbuf_expand() to be
> consistent with tcp_sndbuf_expand().

BTW we renamed the function only because it was used both for initial
sizing, and from tcp_new_space()

As is, tcp_fixup_rcvbuf() is only called at connection setup.
