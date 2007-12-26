From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [IPROUTE2] Compatibility with iptables 1.4.0
Date: Wed, 26 Dec 2007 11:59:09 +0100
Message-ID: <477233FD.2040502@netfilter.org>
References: <20071224160739.M84357@visp.net.lb>	 <1198513837.4427.8.camel@localhost> <1198515457.4427.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57629 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751991AbXLZLGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 06:06:10 -0500
In-Reply-To: <1198515457.4427.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

jamal wrote:
> Pablo, below looks an oversight.
> I think there are some libraries like the mark target need also to be
> backward compatible.

Shouldn't "mark" be in capital letters?

>> lilsol:~# export IPTABLES_LIB_DIR=/root/iptables-1.4.0/extensions/
>> lilsol:~# tc actions add action ipt -j TOS --set-tos
                                          ^^^
                                         this is OK

>> lilsol:~# tc actions add action ipt -j mark --set-mark 3
                                          ^^^
                                          MARK

I'm sorry for the breakage. We definitely need a library for iptables so
this sort of stuff would not happen :(

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
