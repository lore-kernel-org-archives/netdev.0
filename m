From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH V2] tcp: introduce raw access to experimental
 options
Date: Tue, 08 Jan 2013 14:30:12 -0800 (PST)
Message-ID: <20130108.143012.1830129306456354509.davem@davemloft.net>
References: <1357575210-52926-2-git-send-email-elelueck@linux.vnet.ibm.com>
	<1357577051.6919.3171.camel@edumazet-glaptop>
	<50EC2EF3.5080506@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ubacher@de.ibm.com,
	raspl@de.ibm.com, frankbla@de.ibm.com, samudrala@us.ibm.com
To: elelueck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AHWaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 17:30:13 -0500
In-Reply-To: <50EC2EF3.5080506@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just want you to know that I've very displeased with this
feature.

These things belong in a controlled environment in our TCP stack, so
hack our TCP stack if you want to play with experimental TCP options.

I do not want to add ways to poke around, either via socket options
or completely opaque interfaces exported to modules, with TCP options.

Sorry.
