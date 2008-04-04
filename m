From: Patrick McHardy <kaber@trash.net>
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Date: Fri, 04 Apr 2008 15:40:55 +0200
Message-ID: <47F62FE7.9060508@trash.net>
References: <47F61B5C.8090105@trash.net> <20080404132525.GB29904@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Patrick McHardy <kaber@trash.net>, acme@redhat.com,
	dccp@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38133 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbYDDNkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 09:40:53 -0400
In-Reply-To: <20080404132525.GB29904@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker wrote:
> Arnaldo,
> 
> just a thought - I recall that there used to be a bug related to this,
> which required to insert the following before sending an skb:
>      
>      memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt))
> 
> This was about 1+1/2 .. 2 years ago and lead to crashes when the memset
> was removed. Maybe with this solution the memsets are then no longer
> necessary? The reference is
>  * output.c:dccp_transmit_skb()
>  * ipv4.c:dccp_v4_send_response()


Yes, that shouldn't be needed anymore with this patch.

