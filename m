From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4 NETLINK]: Unhash sockets correctly
Date: Wed, 16 Feb 2005 11:52:55 -0800
Message-ID: <20050216115255.107b6641.davem@davemloft.net>
References: <421396D9.2030405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <421396D9.2030405@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 19:54:17 +0100
Patrick McHardy <kaber@trash.net> wrote:

> this patch fixes a nasty bug introduced by the pid-hash backport.
> Sockets are only unhashed if they are contained in the first hash
> bucket. This leads to leaking sockets and, over time, to bind
> conflicts which confuse iproute and result in sporadic failure.

Good catch Patrick.  Applied, and I'll push upstream momentarily.
