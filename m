From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11 PKT_SCHED]: ipt action: add back pskb_expand_head
 call
Date: Sun, 6 Feb 2005 22:04:11 -0800
Message-ID: <20050206220411.643e6afe.davem@davemloft.net>
References: <4202E7BE.6050606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4202E7BE.6050606@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 04 Feb 2005 04:10:54 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Jamal asked me to add back the call to pskb_expand_head before 2.6.11.
> This fixes a regression caused by my tc action cleanup patches, the
> tc actions most not replace packets, so it must prevent netfilter from
> doing so.

Applied, thanks Patrick.
