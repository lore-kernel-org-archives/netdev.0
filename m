From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] net: adding memory barrier to the poll and receive
	callbacks
Date: Mon, 29 Jun 2009 19:19:26 +0200
Message-ID: <20090629171926.GB2742@ami.dom.local>
References: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com> <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, davidel@xmailserver.org,
	eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:38588 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbZF2RTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 13:19:35 -0400
Content-Disposition: inline
In-Reply-To: <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 04:14:45PM +0200, Jiri Olsa wrote:
...
> +static inline void sock_poll_wait(struct file *filp, struct sock *sk,
...
> +	sock_poll_wait(file, sk->sk_sleep, wait);

-----------------------------^^^^^^^^^^^^
Is it something with my eyes or it wasn't compiled? ;-)

Jarek P.
