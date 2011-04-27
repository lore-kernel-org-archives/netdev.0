From: Tomas Carnecky <tom@dbservice.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in ip_fragment
Date: Wed, 27 Apr 2011 13:52:30 +0200
Message-ID: <4DB8037E.7010207@dbservice.com>
References: <20110426203154.GM15903@stratus.com>	 <20110426.134637.48491363.davem@davemloft.net>	 <1303851185.2699.7.camel@edumazet-laptop>	 <20110426205901.GN15903@stratus.com>	 <1303851718.2699.8.camel@edumazet-laptop>	 <20110426211946.GO15903@stratus.com>	 <1303853047.2699.15.camel@edumazet-laptop>  <4DB7C44D.60306@dbservice.com> <1303890067.3166.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from office.neopsis.com ([78.46.209.98]:60572 "EHLO
	office.neopsis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182Ab1D0Lwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 07:52:40 -0400
In-Reply-To: <1303890067.3166.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/11 9:41 AM, Eric Dumazet wrote:
> netconsole=4444@192.168.20.108/eth0,4444@192.168.20.112/00:1e:0b:ec:c3:e4
I'm not having any luck with the netconsole. The last message I see on 
the target host is "Freeing unused kernel memory: 100k freed". I don't 
see any messages after that. Do I need to configure the same IP address 
in netconsole as is later configured by userspace? I set netconsole to 
use 192.168.0.50 while the init scripts set br0 to have 192.168.0.82. 
And would netconsole even work, as the bug is in the networking code itself?


