From: "David S. Miller" <davem@redhat.com>
Subject: Re: tunnel xmit and h.raw
Date: Fri, 3 Oct 2003 08:05:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003080543.5d8e8d41.davem@redhat.com>
References: <20031003073039.7ca1a76c.davem@redhat.com>
	<Pine.LNX.4.44.0310031750390.2761-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310031750390.2761-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 17:56:35 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	The same place, but this one is special: h.raw is updated
> for us on reallocation but if the skb is shared I do not know if this is
> fatal for the other skb users, we change also their h.raw.

Sorry, replying again... I hadn't read your reply correctly.

Indeed, I have to think about what changing skb->h.raw might do
to other users, it might indeed be an issue.
