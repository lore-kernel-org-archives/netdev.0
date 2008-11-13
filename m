From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Thu, 13 Nov 2008 15:03:42 -0800 (PST)
Message-ID: <20081113.150342.26349899.davem@davemloft.net>
References: <b6fcc0a0811131453l4c111135p7b58453a533693ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752276AbYKMXDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 18:03:44 -0500
In-Reply-To: <b6fcc0a0811131453l4c111135p7b58453a533693ea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexey Dobriyan" <adobriyan@gmail.com>
Date: Fri, 14 Nov 2008 01:53:26 +0300

> Something is wrong with read_pnet() as nobody suggested to mass use it
> or send a patch doing it.
> 
>         #ifdef CONFIG_NET_NS
>                 ib->ib_net = net;
>         #endif
> 
> It's _obvious_ from this code that it's a C assignment or nop. It's also
> obvious depending on what config option.

obvious, but ugly

>         write_pnet(&ib->ib_net, net);
> 
> What is & operator doing here? Is it important? '&' is syntaxic noise.

'&' is necessary for the assignment.
