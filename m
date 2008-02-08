From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Thu,  7 Feb 2008 21:32:30 -0800
Message-ID: <47abe7b1.20588c0a.7013.75b7@mx.google.com>
References: <47AAD203.4030706@cosmosbay.com>
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:56623 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbYBHFZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 00:25:07 -0500
Received: by rv-out-0910.google.com with SMTP id k20so2446434rvb.1
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2008 21:25:06 -0800 (PST)
In-Reply-To: <47AAD203.4030706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Or maybe use percpu storage for that...

That seems like a good approach.  I'll incorporate it into my v6 patch,
and send out an update.  Thanks.

> I am not sure if cookie_hash() is always called with preemption disabled.
> (If not, we have to use get_cpu_var()/put_cpu_var())

cookie_hash is always called within NET_RX_SOFTIRQ context so I believe
preemption will always be disabled by __do_softirq().  So there
shouldn't be a need to use get_cpu_var/put_cpu_var, somebody correct me
if I'm wrong.

--Glenn

