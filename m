From: "David S. Miller" <davem@redhat.com>
Subject: Re: register_netdevice return val fix
Date: Sun, 19 Oct 2003 00:07:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031019000755.56c63797.davem@redhat.com>
References: <20031018190014.60ad6344.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031018190014.60ad6344.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 19:00:14 -0700
Andrew Morton <akpm@osdl.org> wrote:

> If the driver's init function returns an error code (most likely -ENODEV),
> register_netdevice will stomp on it and will always return -EIO.
> 
> You end up always getting an "Input/Output error" from modprobe, which is
> confusing.
> 
> Fix register_netdevice() to return the init function's error code, if it
> looks sane.

Looks fine, applied.

Thanks Andrew.
