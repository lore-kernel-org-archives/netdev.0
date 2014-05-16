From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] pktgen: Add NOINIT option to leave packet data
 uninitialized
Date: Fri, 16 May 2014 15:50:32 +0100
Message-ID: <20140516145032.GD8346@casper.infradead.org>
References: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch>
 <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
 <53761286.2040505@candelatech.com>
 <1400250203.7973.173.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39936 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757395AbaEPOuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 10:50:35 -0400
Content-Disposition: inline
In-Reply-To: <1400250203.7973.173.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/14 at 07:23am, Eric Dumazet wrote:
> pktgen has already a way to send fragments which are not memset for
> every packet. We share a 'zero' page for that.
> 
> So only headers need to be really built for each packet.

Right, F_NOINIT is exclusively for cases where a linear buffer is
desired. I don't fully understand the argument of exposing kernel
memory as root considering the presence of /dev/mem though.

That said, I understand that this is a special case and that the
objective is reachable with non linear skbs already so I'm fine
with ignoring this patch and have it linger outside of the tree for
whoever has use for it.
