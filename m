From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix ax25_get_socket locking
Date: Mon, 14 Mar 2005 21:30:15 -0800
Message-ID: <20050314213015.1b113610.davem@davemloft.net>
References: <20050314083744.GA12765@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
In-Reply-To: <20050314083744.GA12765@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 08:37:44 +0000
Ralf Baechle DL5RB <ralf@linux-mips.org> wrote:

> In an attempt to return a locked socket ax25_get_socket() was calling
> lock_sock() with a spinlock held, bad idea.  Making matters worse it's
> only user is running in bottom half context resulting in a potencial
> attempt to sleep in bottom half context, so fix the locking there as well.

Looks fine.  Applied, thanks Ralf.
