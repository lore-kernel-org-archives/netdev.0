From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bluetooth BUG() in set_sk_owner().
Date: Thu, 11 Sep 2003 18:22:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911182223.2e9b7118.davem@redhat.com>
References: <1063184337.32473.529.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, makx@qualcomm.com,
   marcel@holtmann.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063184337.32473.529.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Sep 2003 09:58:57 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> It loks like the recent addition of sk_set_owner() to 
> bt_sock_alloc() was bogus... some of the callers of bt_sock_alloc()
> already do that for  This patch reverts it, and makes the remaining
> callers also set the owner for themselves...

Applied, thanks David.
