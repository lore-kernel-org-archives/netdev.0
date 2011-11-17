From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv4: avoid to double release dst in tcp_v4_connect
Date: Fri, 18 Nov 2011 07:54:46 +0800
Message-ID: <CAJFZqHwqVaysix4=s9MOHWuUuTx0hr3nEkc=ZJA5ajCh4fJf-g@mail.gmail.com>
References: <1321518828-4288-1-git-send-email-roy.qing.li@gmail.com>
	<20111117.165601.715150304040818603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dy0-f46.google.com ([209.85.220.46]:60766 "EHLO
	mail-dy0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476Ab1KQXys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 18:54:48 -0500
Received: by dyi18 with SMTP id 18so193268dyi.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 15:54:47 -0800 (PST)
In-Reply-To: <20111117.165601.715150304040818603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/18 David Miller <davem@davemloft.net>:
> We set 'rt' to NULL at these statements specifically to handle this
> situation, ip_rt_put(NULL) will do nothing.
>
> I don't think this change is necessary.
>

Yes, I am wrong, thank you.
