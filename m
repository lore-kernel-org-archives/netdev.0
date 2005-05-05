From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Thu, 5 May 2005 14:34:12 -0700
Message-ID: <20050505143412.0fe9ebca.davem@davemloft.net>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
	<200412270417.iBR4HZRG021429@toshiba.co.jp>
	<427A79C0.4020103@trash.net>
	<427A7FF5.4030900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, usagi-users@linux-ipv6.org,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        laforge@gnumonks.org, pb@bieringer.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427A7FF5.4030900@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 22:20:05 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > Yasuyuki Kozakai wrote:
> > 
> >>Well, the Multicast Listener Report seems that skb->data != skb->nh.ipv6h
> >>when interface is up. But IPv6 netfilter modules assumes that
> >>skb->data == skb->nh.ipv6h like IPv4 netfilter modules.
> >>
> >>folks, is this wrong or bad asumption ? If so, I'll fix this problem in
> >>many modules as follows.
> > 
> > 
> > Sorry for getting back to this so late, I must have missed it at the
> > time. Anyway, I think it would be safer to restore netfilters assumption
> > by doing something like this patch. If everyone is fine with it I'm
> > going to add it to my pending netfilter patches for 2.6.13.
> 
> The last patch left some unreachable code.

This looks OK with me, I hope it doesn't inadvertantly break anything.
