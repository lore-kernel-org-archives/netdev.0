From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] LLTX for tg3
Date: Sun, 12 Sep 2004 16:45:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912164516.6960ffe8.davem@davemloft.net>
References: <20040907121841.GA4398@wotan.suse.de>
	<5cac192f040912100616feb28a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f040912100616feb28a@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Sep 2004 19:06:26 +0200
Eric Lemoine <eric.lemoine@gmail.com> wrote:

> > Add LLTX suppor to tg3.  Locking was already safe for it, so only
> > trivial changes.
> 
> tg3_set_rx_mode() (dev->set_multicast_list()) and tg3_start_xmit()
> used to synchronise thanks to dev->lock_xmit. With your LLTX patches
> they don't synchronise anymore (I don't think tg3_set_rx_mode() grabs
> tp->tx_lock) ; isn't it an issue?

You're absolutely right, I've made tg3_set_rx_mode() grab the
tx_lock now too.

Good spotting Eric.
