From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PATCH 1/1: [SKBUFF] move common code to hdlc_type_trans
Date: Sat, 9 Oct 2004 00:36:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008223611.GA7097@electric-eye.fr.zoreil.com>
References: <4165F5B2.5040807@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <4165F5B2.5040807@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@conectiva.com.br> :
[dscc4.c sets skb->mac.raw after hdlc_type_trans]
> 	Francois, is this really what is intended? I left it as

In the pre-eth_type_trans area, yes :o/ I did not test dscc4 in
a bridged setup. Please fix the driver in your patch.

--
Ueimor
