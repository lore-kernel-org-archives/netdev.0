From: jamal <hadi@cyberus.ca>
Subject: Re: AF_KEY extended xfrm_state selector handling
Date: Thu, 19 Oct 2006 20:59:32 -0400
Message-ID: <1161305972.5034.58.camel@jzny2>
References: <200610191626.k9JGQ7x4014606@gateplz.comstar.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19330 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1946774AbWJTA7g
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 20:59:36 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Gaijd-00048b-7S
	for netdev@vger.kernel.org; Thu, 19 Oct 2006 20:59:41 -0400
To: Michal Ruzicka <michal.ruzicka@comstar.cz>
In-Reply-To: <200610191626.k9JGQ7x4014606@gateplz.comstar.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-19-10 at 18:26 +0100, Michal Ruzicka wrote:
> Hello
> 
> In an effort to configure an L2TP/IPsec server on Linux capable of supporting
> multiple clients behind a single NAT device I ran into difficulties with pf_key
> protocol implementation not being able to exploit all the information
> passed to it as a SADB_EXT_ADDRESS_PROXY info. Perhaps as the original source
> suggested (/* Nobody uses this, but we try. */) this info has never been used
> before.


BTW, why not use xfrm instead? Then you dont have to worry about racoon.
Unless you care about running this in some other OS (I suspect these
OSes probably have made use of SADB_EXT_ADDRESS_PROXY so that may be a
futile effort in any case).


cheers,
jamal

PS:- Nothing stands out for me in your patch, so i have no comment; i
wasnt sure if the concept of tcp/udp port meant much to the concept of a
security association


