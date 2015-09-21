From: Christoph Schulz <develop@kristov.de>
Subject: Re: [iproute2 PATCH] ip-link: do not support 'ip link add dev
 help'
Date: Mon, 21 Sep 2015 22:13:49 +0200
Message-ID: <20150921221349.83034aoqadvokjr1@berry.schulz.ip-v6.eu>
References: <CAK8ArgOM2Vyr4DJO73wzhgFFbGMm9p+XMGcD2JAWeZ8G+_3PSw@mail.gmail.com>
 <1442863981-19112-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Wilhelm Wijkander <lists@0x5e.se>,
	Vadim Kochan <vadim4j@gmail.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1137-han.de-nserver.de ([77.75.249.171]:54640 "EHLO
	server1137-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754685AbbIUUNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 16:13:54 -0400
In-Reply-To: <1442863981-19112-1-git-send-email-phil@nwl.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Phil Sutter schrieb am Mon, 21 Sep 2015 21:33:01 +0200:

> Commit 0532555 ('Support "ip link add help" for rtnl_link API') added a
> check for specified help parameter. Though due to the place where it has
> been added to, it is not possible anymore to force a given parameter to
> be interpreted as interface name by prefixing it with 'dev '. Fix this
> by forcing whatever follows 'dev' to be presumed as interface name.

I proposed a similar fix which also handles other ip commands, see  
http://patchwork.ozlabs.org/patch/519171/ . Does my patch also work  
for you?


Regards,

Christoph Schulz
