From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Check for leaf-class when classifying by priority
Date: Tue, 18 Nov 2003 17:37:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118173700.213b646b.davem@redhat.com>
References: <3FB39CA2.401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB39CA2.401@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2003 16:00:50 +0100
Patrick McHardy <kaber@trash.net> wrote:

> this patch makes htb_classify check if a class is a leaf when classifying
> by priority. It also adds a check from cbq to skip htb_find if the majors
> of skb->priority and sch->handle differ.

I'm going to hold on this patch for two reasons:

1) To allow Martin to respond and review it.
2) I want the OOPS'er we have pending on the HTB scheduler
   resolved first.

Martin, have you made any progress with that HTB 2.6.x oops
issue yet?

Thanks guys.
