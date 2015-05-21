From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next 1/2] inet_hashinfo: remove bsocket counter
Date: Thu, 21 May 2015 17:10:27 -0300
Message-ID: <20150521201027.GH2379@x240.home>
References: <1432144742-17786-1-git-send-email-edumazet@google.com>
 <1432144742-17786-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067AbbEUUKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 16:10:32 -0400
Content-Disposition: inline
In-Reply-To: <1432144742-17786-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 10:59:01AM -0700, Eric Dumazet wrote:
> We no longer need bsocket atomic counter, as inet_csk_get_port()
> calls bind_conflict() regardless of its value, after commit
> 2b05ad33e1e624e ("tcp: bind() fix autoselection to share ports")
> 
> This patch removes overhead of maintaining this counter and
> double inet_csk_get_port() calls under pressure.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Cc: Flavio Leitner <fbl@redhat.com>
> ---

The patch looks good to me.
Acked-by: Flavio Leitner <fbl@redhat.com>
