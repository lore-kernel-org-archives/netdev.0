From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 3/3] unix/stream: fix peeking with an offset larger
 than data in queue
Date: Mon, 29 Apr 2013 17:51:00 -0700
Message-ID: <1367283060.8964.336.camel@edumazet-glaptop>
References: <kll5si$544$1@ger.gmane.org>
	 <1367271734-14379-1-git-send-email-bpoirier@suse.de>
	 <1367271734-14379-3-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367271734-14379-3-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-04-29 at 17:42 -0400, Benjamin Poirier wrote:
> Currently, peeking on a unix stream socket with an offset larger than len of
> the data in the sk receive queue returns immediately with bogus data.
> 
> This patch fixes this so that the behavior is the same as peeking with no
> offset on an empty queue: the caller blocks.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> ---
>  net/unix/af_unix.c |   25 ++++++++++++-------------
>  1 file changed, 12 insertions(+), 13 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
