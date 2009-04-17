From: David Miller <davem@davemloft.net>
Subject: Re: htb parallelism on multi-core platforms
Date: Fri, 17 Apr 2009 04:31:51 -0700 (PDT)
Message-ID: <20090417.043151.61240311.davem@davemloft.net>
References: <1239964844.21569.57.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: radu.rendec@ines.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757550AbZDQLcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 07:32:00 -0400
In-Reply-To: <1239964844.21569.57.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radu Rendec <radu.rendec@ines.ro>
Date: Fri, 17 Apr 2009 13:40:44 +0300

> Is there any (simple) approach to distribute htb work (for one
> interface) on multiple cpus?

HTB acts upon global state, so anything that goes into a particular
device's HTB ruleset is going to be single threaded.

There really isn't any way around this.
