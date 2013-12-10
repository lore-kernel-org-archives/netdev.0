From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 6/6] net_sched: make macro be enclosed in parenthesis
Date: Tue, 10 Dec 2013 13:01:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7477@saturn3.aculab.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com> <1386680134-85452-7-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Yang Yingliang" <yangyingliang@huawei.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38042 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751401Ab3LJNCk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 08:02:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21117-09 for <netdev@vger.kernel.org>;
 Tue, 10 Dec 2013 13:02:37 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386680134-85452-7-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  #define SKIP_NONLOCAL(skb)			\
> +({						\
>  	if (unlikely(skb->sk == NULL)) {	\
>  		*err = -1;			\
>  		return;				\
> -	}
> +	}					\
> +})

That one should be lined up against the fence and shot :-)
