From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: External interface changes
Date: Fri, 25 Apr 2008 00:16:18 +0200
Message-ID: <200804250016.19280.tomasz@grobelny.oswiecenia.net>
References: <200804222230.25743.tomasz@grobelny.oswiecenia.net> <20080424220704.0483DBC12@poczta.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2194 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143AbYDXWQ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 18:16:29 -0400
In-Reply-To: <20080424220704.0483DBC12@poczta.oswiecenia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Thursday 24 of April 2008, napisa=B3e=B6:
> +	skb->priority =3D info.priority;
Here, as David pointed out, we are not sure wheter skb->priority can be=
 used.=20
But that's not the point of this patch. The point is to request for com=
ment=20
when it comes to separation of externally visible interface and interna=
l per=20
skb data storage.

> +	printk("pushing prio: %d\n", skb->priority);
And that is of course a simple mistake.
--=20
Regards,
Tomasz Grobelny
