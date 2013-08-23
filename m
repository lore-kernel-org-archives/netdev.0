From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qlge: feature update
Date: Thu, 22 Aug 2013 22:12:46 -0700 (PDT)
Message-ID: <20130822.221246.527881072702590889.davem@davemloft.net>
References: <1377201252-9283-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab3HWFMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 01:12:51 -0400
In-Reply-To: <1377201252-9283-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Thu, 22 Aug 2013 15:54:10 -0400

> This patch series enhance the handling of nested vlan tags in Rx path.

Sorry no module parameters.

You must make a generic, kernel wide, interface for controlling behavior
such as this.

Otherwise users will need to learn unique configuration mechanisms
to control this kind of thing for every single driver and that's
beyond terrible.

I'm not applying these patches.
