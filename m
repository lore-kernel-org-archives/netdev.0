From: "David S. Miller" <davem@redhat.com>
Subject: Re: Use NET_IP_ALIGN in acenic
Date: Sat, 24 Jul 2004 22:41:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724224136.070b6c36.davem@redhat.com>
References: <20040724174348.GL4556@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jes@trained-monkey.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040724174348.GL4556@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 25 Jul 2004 03:43:48 +1000
Anton Blanchard <anton@samba.org> wrote:

> 
> Use NET_IP_ALIGN in acenic driver. Also remove the 16 byte padding,
> caches can be anywhere from 16 to 256 bytes and the skb should be
> cacheline aligned already.

Looks fine to me, applied.  Thanks Anton.
