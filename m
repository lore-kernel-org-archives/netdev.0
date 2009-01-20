From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: why usr/include/linux/if_frad.h is required
Date: Tue, 20 Jan 2009 20:22:54 +0530
Message-ID: <1232463174.3088.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: mike.mclagan@linux.org, Ingo Molnar <mingo@elte.hu>,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:52127 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902AbZATOx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 09:53:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For if_frad.h I am getting two warnings with 'make headers_check':
  usr/include/linux/if_frad.h:29: leaks CONFIG_DLCI to userspace where it is not valid
  usr/include/linux/if_frad.h:129: leaks CONFIG_DLCI to userspace where it is not valid

Almost all if_frad.h is covered with #if defined(CONFIG_DLCI) || defined(CONFIG_DLCI_MODULE) 

If I remove this portion so only this what we get in userspace:

#ifndef _FRAD_H_
#define _FRAD_H_

#include <linux/if.h>

#endif

So I am surprising what is the point of this ? 

Can I change its name to is_fraud ;-)

--
JSR

