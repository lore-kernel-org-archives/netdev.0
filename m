From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] tcp: unify tcp flag macros
Date: Sat, 12 Jun 2010 10:18:12 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006121017380.28286@obet.zrqbmnf.qr>
References: <1276322372-12584-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276322372-12584-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2010-06-12 07:59, Changli Gao wrote:
>--- a/include/net/tcp.h
>+++ b/include/net/tcp.h
>@@ -602,6 +602,17 @@ extern u32	__tcp_select_window(struct sock *sk);
>  */
> #define tcp_time_stamp		((__u32)(jiffies))
> 
>+#define tcp_flag_byte(th) (((u_int8_t *)th)[13])
>+
>+#define	TH_FIN	0x01
>+#define	TH_SYN	0x02
>+#define	TH_RST	0x04
>+#define	TH_PUSH	0x08
>+#define	TH_ACK	0x10
>+#define	TH_URG	0x20
>+#define	TH_ECE	0x40
>+#define	TH_CWR	0x80

I'd prefer something less generic, like TCPHDR_{FIN,SYN,etc}.

