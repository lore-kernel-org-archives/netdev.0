From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 06:45:16 -0700
Message-ID: <1364478316.15753.43.camel@edumazet-glaptop>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
	 <1364478265.15753.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34169 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab3C1NpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:45:19 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so4129916pde.4
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 06:45:18 -0700 (PDT)
In-Reply-To: <1364478265.15753.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 06:44 -0700, Eric Dumazet wrote:

> __in6_dev_get() should be OK.

more exactly : __in_dev_get_rtnl()
