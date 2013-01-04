From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Thu, 03 Jan 2013 22:54:51 -0800
Message-ID: <1357282491.21409.28211.camel@edumazet-glaptop>
References: <CA+icZUVEvzyrPsQG1QWLnHxhtaewaWTOVzBpTnLqjKuHMjjFHg@mail.gmail.com>
	 <1357219919.21409.24519.camel@edumazet-glaptop> <50E5DEEF.2080009@hp.com>
	 <1357274510.21409.27807.camel@edumazet-glaptop>
	 <CA+icZUVWKD7j=E90Tqvy8BQR7GWtakYyN7CAG5Z7-OO9GJuJPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:49397 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab3ADGyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 01:54:54 -0500
In-Reply-To: <CA+icZUVWKD7j=E90Tqvy8BQR7GWtakYyN7CAG5Z7-OO9GJuJPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 06:31 +0100, Sedat Dilek wrote:

> 
> Will you send a v2 with this change...?
> 
> -#define MAX_SOFTIRQ_TIME  min(1, (2*HZ/1000))
> +#define MAX_SOFTIRQ_TIME  max(1, (2*HZ/1000))

I will, I was planning to do this after waiting for other
comments/reviews.
