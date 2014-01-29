From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 multiple routing tables - all routes were added to main
 table
Date: Wed, 29 Jan 2014 15:17:17 -0800
Message-ID: <52E98BFD.40306@candelatech.com>
References: <CAMBtn_0S0K6eydjTLJAsVqbKVuJ+tc7k30OUWRxscm+gP6y2EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Asi Lichtenstein <asili22@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42881 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaA2XRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 18:17:19 -0500
In-Reply-To: <CAMBtn_0S0K6eydjTLJAsVqbKVuJ+tc7k30OUWRxscm+gP6y2EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2014 01:38 AM, Asi Lichtenstein wrote:
> Hi there,
> 
> I'm using an old kernel 2.6.16 where i applied this patchset:
> http://thread.gmane.org/gmane.linux.network/41149/focus=41150
> 
> i was able to create new table but all routes I've added to specific
> table were added to main table.

No idea if your patches will work on that ancient kernel.  Did you update
your ip tool as well?

try:  ip route show table X

and show us what commands you used to try to add the routes to a specific
table?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
