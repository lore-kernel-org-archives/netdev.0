From: Julian Anastasov <ja@ssi.bg>
Subject: Re: tunnel xmit and h.raw
Date: Fri, 3 Oct 2003 17:56:35 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310031750390.2761-100000@l>
References: <20031003073039.7ca1a76c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031003073039.7ca1a76c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 3 Oct 2003, David S. Miller wrote:

> > 	Is the following change needed? May be yes for all kernels
> > where the nearest skb_shared checks are actual.
>
> There seems to be no end to these kinds of bugs in the tunnel
> drivers!
>
> Didn't we fix a nearly identical set of bugs in the tunnel
> drivers just a month or two ago?

	The same place, but this one is special: h.raw is updated
for us on reallocation but if the skb is shared I do not know if this is
fatal for the other skb users, we change also their h.raw. But I rely
on your opinion, may be it is safer with this change.

> I'll review this some more tomorrow and unless I find some problem
> I'll apply your patch.  Thanks a lot.

Regards

--
Julian Anastasov <ja@ssi.bg>
