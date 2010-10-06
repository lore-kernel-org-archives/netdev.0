From: Joe Perches <joe@perches.com>
Subject: drivers/net/Makefile - question about link order comment
 introduced in 2.3.43
Date: Wed, 06 Oct 2010 04:04:09 -0700
Message-ID: <1286363049.2156.113.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2689 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422Ab0JFLEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 07:04:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It wasn't that way in 2.3.43-pre7 , but it is in 2.3.43
and has remained there since.  There's nothing in lkml
history as far as I can find to describe a reason for it.

http://lkml.org/lkml/2000/2/10
(or thereabout)

Anyone know why it's like that or if that Makefile link
ordering is still needed?

Currently, drivers/net/Makefile line 42

#
# link order important here
#
obj-$(CONFIG_PLIP) += plip.o

[about 60 lines later...]

obj-$(CONFIG_STMMAC_ETH) += stmmac/

#
# end link order section
#


