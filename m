From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] cxgb3: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 14:24:37 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC6@saturn3.aculab.com>
References: <CAPgLHd9b+0DDZ9iYFzNS4NP1w_3GmWaMD+ihqeVeEGXei9cfUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <yongjun_wei@trendmicro.com.cn>, <netdev@vger.kernel.org>
To: "Wei Yongjun" <weiyj.lk@gmail.com>, <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33723 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751781Ab2H1NgA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:36:00 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21274-05 for <netdev@vger.kernel.org>;
 Tue, 28 Aug 2012 14:35:57 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <CAPgLHd9b+0DDZ9iYFzNS4NP1w_3GmWaMD+ihqeVeEGXei9cfUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	if (t->nofail_skb)
> -		kfree_skb(t->nofail_skb);
> +	kfree_skb(t->nofail_skb);

Some of these conditionals might be there for performance
reasons - eg if common path and normally NULL.

	David
