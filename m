From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 PKT_SCHED]: Fix scheduler/classifier module unload
 race
Date: Tue, 9 Nov 2004 21:46:11 -0800
Message-ID: <20041109214611.267a79d5.davem@davemloft.net>
References: <418EA497.10302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418EA497.10302@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 07 Nov 2004 23:41:27 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes an scheduler/classifier module unload race.
> struct Qdisc_ops which includes the owner field is also part
> of the module's memory, so ops might already be freed when
> try_module_get(ops->owner) is called outside of the locked
> section.

Applied, thanks a lot Patrick.
