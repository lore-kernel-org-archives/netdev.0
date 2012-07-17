From: David Miller <davem@davemloft.net>
Subject: Re: That's pretty much it for 3.5.0
Date: Tue, 17 Jul 2012 15:18:32 -0700 (PDT)
Message-ID: <20120717.151832.1306978935355646723.davem@davemloft.net>
References: <5005D008.6060103@intel.com>
	<20120717.140241.1599386555723262095.davem@davemloft.net>
	<5005E390.7020706@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab2GQWSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:18:33 -0400
In-Reply-To: <5005E390.7020706@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 17 Jul 2012 15:13:36 -0700

> Perhaps the easiest way is to check net->count this should be zero
> until setup_net is called.
> 
> if (!atomic_read(&init_net.count))
> 	return ret;
> 

Won't work, setup_net() runs via a pure_initcall().
