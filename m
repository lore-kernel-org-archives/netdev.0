From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 4/9] X.25: Stop x25_destroy_socket timer looping
Date: Thu, 28 Oct 2004 16:45:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164547.509b90f9.davem@davemloft.net>
References: <200410280721.i9S7Lf907993@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Lf907993@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:42 -0700
akpm@osdl.org wrote:

> From: Andrew Hendry <ahendry@tusc.com.au>
> 
> The sk_timer.data for the x.25 destroy_socket timer went missing at some
> stage, causing a timer loop where x25_destroy_socket would keep setting up
> timers to call itself.  This patch puts the sk_timer.data back.
> 
> Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
