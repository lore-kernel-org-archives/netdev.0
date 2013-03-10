From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] Remove unused tw_cookie_values from tcp_timewait_sock
Date: Sun, 10 Mar 2013 17:33:52 +0100
Message-ID: <1728893.EzBGFb9CIE@cpaasch-mac>
References: <1362928719-13532-1-git-send-email-christoph.paasch@uclouvain.be> <1362931570.4051.34.camel@edumazet-glaptop>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	william.allen.simpson@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35936 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab3CJQd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 12:33:59 -0400
In-Reply-To: <1362931570.4051.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 10 March 2013 17:06:10 Eric Dumazet wrote:
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Actually, I am not sure TCPCT is really used...

Yes, while looking through the code it seems to me that it is far from 
respecting RFC 6013.

It uses 253 as option-number and has comments saying "not yet implemented" 
(e.g., tcp_parse_options).

Should it be removed?


Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
