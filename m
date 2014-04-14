From: Martin Filip <nexus+kernel@smoula.net>
Subject: Re: TUN device performance regression
Date: Mon, 14 Apr 2014 13:42:39 +0200
Message-ID: <1397475759.12568.0.camel@interceptor.in.smoula.net>
References: <1397475118.11864.5.camel@interceptor.in.smoula.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scarab.smoula.net ([83.240.14.6]:42542 "EHLO scarab.smoula.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754663AbaDNLmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 07:42:47 -0400
Received: from localhost (localhost [127.0.0.1])
	by scarab.smoula.net (Postfix) with ESMTP id 16B162605A
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 13:42:46 +0200 (CEST)
Received: from scarab.smoula.net ([127.0.0.1])
	by localhost (scarab.smoula.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tjsqaH0hJ2Sv for <netdev@vger.kernel.org>;
	Mon, 14 Apr 2014 13:42:40 +0200 (CEST)
Received: from [IPv6:2001:470:5950:b00c::1] (interceptor.smoula.net [IPv6:2001:470:5950:b00c::1])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by scarab.smoula.net (Postfix) with ESMTPSA id 3A7C42550D
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 13:42:40 +0200 (CEST)
In-Reply-To: <1397475118.11864.5.camel@interceptor.in.smoula.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello,
> 
> I've noticed significant TUN device performance drop between 3.13 and
> 3.14 kernels, problem seems to persist until current git version.
> 
> With good kernel I can achieve full 100mbps through openvpn without any
> problem, with problematic kernel TX performance drops down to ~50kbps.
> 
> According to git bisect it seems that root of all evil is commit
> 53d6471cef17262d3ad1c7ce8982a234244f68ec.
> 
> I can confirm that performance is great again with current kernel when I
> revert this one.
> 
I've forgot to mention kernel bug:
https://bugzilla.kernel.org/show_bug.cgi?id=74051

-- 
Martin Filip
e-mail: nexus@smoula.net
jabberID: nexus@smoula.net
http://www.smoula.net
