From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6]: Fix oops in ipt action error path
Date: Wed, 8 Dec 2004 20:57:50 -0800
Message-ID: <20041208205750.56a790fa.davem@davemloft.net>
References: <41B7892E.1080706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B7892E.1080706@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 09 Dec 2004 00:07:26 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes an oops when the ipt action is used with a
> non-existant iptables target. It tries to log
> t->u.kernel.target->name, u.kernel.target is part of a union
> and as long as the target wasn't successfully loaded contains
> the name of the target, using it as a pointer results in a
> crash.

Applied, thanks Patrick.
