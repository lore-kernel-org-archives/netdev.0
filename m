From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] clean up tcp_sk(), 2.6.0
Date: Tue, 30 Dec 2003 14:46:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031230144608.4c7e66f2.davem@redhat.com>
References: <20031230163230.GA12553@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20031230163230.GA12553@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Dec 2003 17:32:30 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> i recently wasted a few hours on a bug where i used "tcp_sk(sock)"
> instead of "tcp_sk(sock->sk)" - the former, while being blatantly
> incorrect, compiles just fine on 2.6.0. The patch below is equivalent to
> the define but is also type-safe. Compiles cleanly & boots fine on
> 2.6.0.

Applied, and I'll happily accept patches for udp_sk() and all
the other ones too :)
