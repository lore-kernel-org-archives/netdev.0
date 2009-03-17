From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] [SK_BUFF]: '< 0' and '>= 0' test on unsigned
Date: Tue, 17 Mar 2009 14:29:30 -0300
Message-ID: <20090317172930.GI22651@ghostprotocols.net>
References: <49BFA8EA.4000702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbZCQRbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 13:31:19 -0400
Content-Disposition: inline
In-Reply-To: <49BFA8EA.4000702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Mar 17, 2009 at 02:43:06PM +0100, Roel Kluin escreveu:
> Was this patch missed?
> 
> struct sk_buff is located at vi include/linux/skbuff.h +357: 
> maybe a different test is needed in x25_rx_call_request()?
> ------------------------------>8-------------8<---------------------------------
> skb->len is an unsigned int, so the test in x25_rx_call_request() always
> evaluates to true.
> 
> len in x25_sendmsg() is unsigned as well. so -ERRORS returned by x25_output()
> are not noticed.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

I saw DaveM applying this one, lemme see...

http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=8db09f26f912f7c90c764806e804b558da520d4f

- Arnaldo
