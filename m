From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.9]: Fix inet6_dev reference leak in ndisc_dst_alloc
 error path
Date: Wed, 20 Oct 2004 22:16:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020221618.114d5026.davem@davemloft.net>
References: <41758EF7.6010906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41758EF7.6010906@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004 00:02:31 +0200
Patrick McHardy <kaber@trash.net> wrote:

> ndisc_dst_alloc leaks a inet6_dev reference when ip6_dst_alloc
> returns NULL. The bug was introduced somewhere between 2.6.8
> and 2.6.9.

Applied, thanks Patrick.
