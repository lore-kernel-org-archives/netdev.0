From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: "Close NETIF_F_LLTX race conditions" problem
Date: Sun, 23 Jan 2005 17:16:53 +0100
Message-ID: <5cac192f05012308167a78efa6@mail.gmail.com>
References: <871xcc5oef.fsf@devron.myhome.or.jp>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <871xcc5oef.fsf@devron.myhome.or.jp>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 23 Jan 2005 21:19:04 +0900, OGAWA Hirofumi
<hirofumi@mail.parknet.co.jp> wrote:
> Hi,
> 
> I got the following warning. The cause of this warning is the context
> of ->hard_start_xmit() was changed. Before that patch the IRQ was
> enableing, but now it was disabled.
> 
> With this change, the assumption of some drivers was changed, so now
> some drivers need to change the ->hard_start_xmit().
> (e.g, dev_kfree_skb() -> dev_kfree_skb_irq(), spin_lock_irq() -> spin_lock()).

This is a known issue (in 2.6.11-rc2). Linus' tree should certainly
include the revert patch at this time.

--
Eric
