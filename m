From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Fri, 22 Mar 2013 07:47:46 -0700
Message-ID: <1363963666.4431.61.camel@edumazet-glaptop>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
	 <514C6CAA.2090902@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Meng, Jilin" <Jilin.Meng@emc.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:50841 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933169Ab3CVOru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:47:50 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so3142378pbc.14
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 07:47:49 -0700 (PDT)
In-Reply-To: <514C6CAA.2090902@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 18:37 +0400, Sergei Shtylyov wrote:

>     Don't we have memcmp() in Linux?
> 

Dont use slow memcmp() in this context but fast
ether_addr_equal_64bits()
