From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Mon, 13 Oct 2003 10:19:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013101935.231fb1fd.davem@redhat.com>
References: <3F87430D.2040000@tpack.net>
	<3F87464B.1020908@candelatech.com>
	<3F874A30.6010700@tpack.net>
	<3F885418.3090407@candelatech.com>
	<20031011120339.0da631e6.davem@redhat.com>
	<3F892629.7090206@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <3F892629.7090206@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Oct 2003 12:00:09 +0200
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> Bear with me, but this is how I understand it:
> 
>   - The sk_buff *structure* is read-only on a shared SKB.
>     skb_share_check(skb) breaks the sharing, thus allowing
>     updates of skb->dev, skb->len etc.
>     But the SKB still points at the same data buffer.
> 
>   - The *data* buffer is read-only on a cloned SKB.
>     skb_cow() or skb_copy() or ... gives us a writeable buffer.

skb_copy() makes both the struct sk_buff and the data it points
to unique and yours alone to modify however you wish.
