From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Sun, 22 Nov 2009 20:18:04 -0800
Message-ID: <adafx856fib.fsf@roland-alpha.cisco.com>
References: <4AF8EBA4.2070102@gmail.com>
	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>
	<adaocn8x6j7.fsf@roland-alpha.cisco.com>
	<8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>
	<4B0628E0.6000404@gmail.com> <adak4xl669z.fsf@roland-alpha.cisco.com>
	<4B063C78.1070502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Hefty <sean.hefty@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Roland Dreier <rolandd@cisco.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma <linux-rdma@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:16156 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233AbZKWER7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2009 23:17:59 -0500
In-Reply-To: <4B063C78.1070502@gmail.com> (Eric Dumazet's message of "Fri, 20
	Nov 2009 07:51:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Its possible to get infinite loops or crashes.

 > I am not a RDMA user, so I personally dont care :)

I think given that it's not a regression, and I've never heard of anyone
hitting it in practice, we can wait until the merge window.

Thanks!
