From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Thu, 10 Apr 2008 20:29:23 -0400
Message-ID: <47FEB0E3.8080507@rtr.ca>
References: <9a8748490804101509l5d043ff8w565dc44dfeaf0072@mail.gmail.com>	<20080410.154651.101700010.davem@davemloft.net>	<47FEADCB.7070104@rtr.ca> <20080410.172648.187059862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, tilman@imap.cc, yoshfuji@linux-ipv6.org,
	jeff@garzik.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([76.10.145.34]:1035 "EHLO mail.rtr.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbYDKA3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 20:29:25 -0400
In-Reply-To: <20080410.172648.187059862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Mark Lord <lkml@rtr.ca>
> Date: Thu, 10 Apr 2008 20:16:11 -0400
> 
>> [c67499c0e772064b37ad75eb69b28fc218752636 is first bad commit
>> commit c67499c0e772064b37ad75eb69b28fc218752636
>> Author: Pavel Emelyanov <xemul@openvz.org>
>> Date:   Thu Jan 31 05:06:40 2008 -0800
>>
>>     [NETNS]: Tcp-v4 sockets per-net lookup.
>>
>>     Add a net argument to inet_lookup and propagate it further
>>     into lookup calls. Plus tune the __inet_check_established.
>>
>>     The dccp and inet_diag, which use that lookup functions
>>     pass the init_net into them.
>>
>>     Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Thanks Mark.
> 
> Pavel can you take a look?  I suspect that the namespace
> changes or gets NULL'd out somehow and this leads to the
> resets because the socket can no longer be found.  Perhaps
> it's even a problem with time-wait socket namespace
> propagation.
..

My system here is now set up for quick/easy retest, if you have any
suggestions or patches to try out.

Thanks guys.
