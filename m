From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH 1/3] UDP memory usage accounting (take 2): fix send
 buffer check
Date: Fri, 28 Sep 2007 13:09:52 -0700 (PDT)
Message-ID: <20070928.130952.111188154.davem@davemloft.net>
References: <46FD03B2.1000706@hitachi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com,
	yoshfuji@linux-ipv6.org
To: satoshi.oshima.fk@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbXI1UJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 16:09:53 -0400
In-Reply-To: <46FD03B2.1000706@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Date: Fri, 28 Sep 2007 22:37:54 +0900

>              } else if (i < MAX_SKB_FRAGS) {
> 
> +                if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
> 
> +                    > 2 * sk->sk_sndbuf) {
> 
> +                    err = -ENOBUFS;
> 
> +                    goto error;
> 
> +                }

Your email client, or something, is adding newlines every
other line of real content, making your patches unusable.

Please go and perform some testing to make sure that the
patches you email out are untouched by the email client and
can be applied by the recipient.
