From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
 catch overflow at build time
Date: Thu, 22 Oct 2009 04:49:14 -0700 (PDT)
Message-ID: <20091022.044914.36401063.davem@davemloft.net>
References: <20091021170732.GE5976@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754362AbZJVLsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 07:48:52 -0400
In-Reply-To: <20091021170732.GE5976@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 21 Oct 2009 21:07:32 +0400

> net,socket: introduce build_sockaddr_check helper to catch overflow at build time
> 
> proto_ops->getname implies copying protocol specific data
> into storage unit (particulary to __kernel_sockaddr_storage).
> So when one implements new protocol he either may keep this
> in mind (or may not).
> 
> Lets introduce build_sockaddr_check helper which check if
> storage unit is not overfowed. Note that the check is build
> time and introduce no slowdown at execution time.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Nice idea, and I wonder if we can automate it even further.
Perhaps some tag that gets put on the socket address type
definition or similar?
