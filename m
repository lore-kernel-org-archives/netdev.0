From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Wed, 07 Nov 2007 08:42:48 -0500
Message-ID: <1194442968.4446.8.camel@localhost>
References: <20071106142558.GC1666@ff.dom.local>
	 <1194360226.4444.39.camel@localhost>
	 <1194368416.2987.218.camel@localhost.localdomain>
	 <20071107.012220.17723288.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: radu.rendec@ines.ro, jarkao2@o2.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:10611 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756399AbXKGNng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 08:43:36 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2809727wah
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2007 05:43:36 -0800 (PST)
In-Reply-To: <20071107.012220.17723288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-11 at 01:22 -0800, David Miller wrote:

> @@ -615,7 +615,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
>  	n->handle = handle;
>  {
>  	u8 i = 0;
> -	u32 mask = s->hmask;
> +	u32 mask = ntohl(s->hmask);


Is this line needed? Radu?

cheers,
jamal



