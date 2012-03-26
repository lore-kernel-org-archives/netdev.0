From: Ben Greear <greearb@candelatech.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Mon, 26 Mar 2012 16:53:46 -0700
Message-ID: <4F71018A.20809@candelatech.com>
References: <4F70E308.7070908@candelatech.com>  <20120326.174945.1186427809261872546.davem@davemloft.net>  <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com> <1332805148.3547.14.camel@edumazet-glaptop> <4F70FFE0.7070204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41963 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757802Ab2CZXxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 19:53:52 -0400
In-Reply-To: <4F70FFE0.7070204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2012 04:46 PM, Ben Greear wrote:
> On 03/26/2012 04:39 PM, Eric Dumazet wrote:

>> Is this problem also appears with current tree ?
>> (This could be a problem with the backport, as it was full of
>> dependencies)
>
> I don't think so..but I will double check in a bit.

3.3.0 (plus a bunch of may non-related patches) appears to
work just fine.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
