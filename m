From: "David S. Miller" <davem@davemloft.net>
Subject: Re: generic 802.11 stack
Date: Tue, 7 Sep 2004 11:08:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907110813.6b463f3a.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<200409072022.14330.vkondra@mail.ru>
	<20040907103203.52199758.davem@davemloft.net>
	<200409072106.28334.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409072106.28334.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Sep 2004 21:06:24 +0300
Vladimir Kondratiev <vkondra@mail.ru> wrote:

> May be I did not stated the question clearly. This information need to be 
> specified per packet. So question ramains: how to specify PHY info per skb.

Use the skb->cb[] area, create:

struct p80211_skb_cb {
	int rate;
	int channel;
	/* whatever... */
};

#define P80211_SKB_CB(skb)  ((struct p80211_skb_cb *)((skb)->cb))
