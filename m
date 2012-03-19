From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: Kernel Panic with bonding + IPoIB on 3.2.9
Date: Mon, 19 Mar 2012 12:05:36 -0700
Message-ID: <CAL1RGDVAd-LiS0sy6RAFNzkUuXrcuGv829nADcnxUnC2tfx3bw@mail.gmail.com>
References: <CAOzFzEiufg40gKBH6D7zeB47SebfPvgzqOLxhF5eQqpYd-r4zQ@mail.gmail.com>
 <CAOzFzEi=UOnwiV+qVks7+RnYU3PFbaQ+3OaEE3YFG2HHuD5ydQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joseph Glanville <joseph.glanville-2MxvZkOi9dvvnOemgxGiVw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAOzFzEi=UOnwiV+qVks7+RnYU3PFbaQ+3OaEE3YFG2HHuD5ydQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 18, 2012 at 1:21 PM, Joseph Glanville
<joseph.glanville-2MxvZkOi9dvvnOemgxGiVw@public.gmane.org> wrote:
> [ =A0422.047024] kernel BUG at net/core/dev.c:1896!

So this line is

        BUG_ON(offset >=3D skb_headlen(skb));

right?  No paritcular idea how we hit this, though...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
