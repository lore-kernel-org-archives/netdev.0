From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: Fix potential memory leak
Date: Tue, 27 Sep 2011 14:07:37 +0200
Message-ID: <1317125257.2541.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+v9cxYuFArVUh9gc-be-Lmy4TOTxp72VaCC4QeCEE3p1j2Ykg@mail.gmail.com>
	 <1317017353.2853.13.camel@edumazet-laptop>
	 <CA+v9cxbd3GjAigHC+P8coconkdHxNF3dBgoRDtbxqZ6oK_Mw0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:61650 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab1I0MH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 08:07:26 -0400
Received: by yib18 with SMTP id 18so5163065yib.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 05:07:26 -0700 (PDT)
In-Reply-To: <CA+v9cxbd3GjAigHC+P8coconkdHxNF3dBgoRDtbxqZ6oK_Mw0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 17:58 +0800, Huajun Li a =C3=A9crit :

> To emulate memory allocation fail case, I added code to return
> '-ENOMEM' from flow_cache_cpu_prepare(...) even if it could allocate
> memory correctly, but did not find panic on my box, maybe the latest
> code changed greatly than 2.6.37. :)

To panic the box, you need to leave a NULL pointer somewhere and
dereference it later, when code assumes it cant be NULL ;)
