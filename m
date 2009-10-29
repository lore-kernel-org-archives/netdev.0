From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
 catch overflow at build time
Date: Thu, 29 Oct 2009 03:00:19 -0700 (PDT)
Message-ID: <20091029.030019.44832583.davem@davemloft.net>
References: <20091023214306.GA30616@lenovo>
	<20091024.061209.39469983.davem@davemloft.net>
	<20091024163226.GA5204@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45889
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbZJ2J7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 05:59:55 -0400
In-Reply-To: <20091024163226.GA5204@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sat, 24 Oct 2009 20:32:26 +0400

> net,socket: introduce DECLARE_SOCKADDR helper to catch overflow at build time
> 
> proto_ops->getname implies copying protocol specific data
> into storage unit (particulary to __kernel_sockaddr_storage).
> So when we implement new protocol support we should keep such
> a detail in mind (which is easy to forget about).
> 
> Lets introduce DECLARE_SOCKADDR helper which check if
> storage unit is not overfowed at build time.
> 
> Eventually inet_getname is switched to use DECLARE_SOCKADDR
> (to show example of usage).
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

I like this, applied to net-next-2.6, thanks!
