From: David Miller <davem@davemloft.net>
Subject: Re: pkt_sched: Control group classifier
Date: Mon, 27 Oct 2008 17:05:24 -0700 (PDT)
Message-ID: <20081027.170524.124746723.davem@davemloft.net>
References: <20081027.123056.22851224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52583
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753481AbYJ1AFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:05:47 -0400
In-Reply-To: <20081027.123056.22851224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 27 Oct 2008 12:30:56 -0700 (PDT)

> 
> Patch applied, thanks a lot Thomas.

Sorry I had to revert this:

1) It can't work as a tristate option, the control group subsystem
   framework doesn't work with modular enables.

   For one thing the cgroup_subsys.h users only CONFIG_FOO tests
   rather than also checking CONFIG_FOO_MODULAR.  And even if added
   that wouldn't work since the symbols don't get exported to modules.

2) There was still a discussion going on about the hardirq/softirq
   tracing bits.  They seem unnecessary.

Please fix this up and resubmit, thanks.
