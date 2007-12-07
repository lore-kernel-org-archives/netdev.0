From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch 0/3][IPV6]: remove ifdef in route6 init/fini functions
Date: Fri, 07 Dec 2007 07:37:26 -0800 (PST)
Message-ID: <20071207.073726.115375003.yoshfuji@linux-ipv6.org>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dlezcano@fr.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43004 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbXLGPhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 10:37:06 -0500
In-Reply-To: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com> (at Fri, 07 Dec 2007 14:13:25 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:

> The route6 init function is a little difficult to read because it contains 
> a lot of ifdef. The patchset redefines the usual static inline functions when
> the code is to be disabled by configuration, so we can call the code without
> taking care of the config option in the init function.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
