From: Ben Greear <greearb@candelatech.com>
Subject: Re: IFF_PROMISC again
Date: Tue, 22 May 2007 17:22:54 -0700
Message-ID: <4653895E.9000801@candelatech.com>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>	<465385F2.7080309@candelatech.com> <20070522.171225.70219741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: martin.ferrari@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:36949 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756919AbXEWAXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 20:23:01 -0400
In-Reply-To: <20070522.171225.70219741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 22 May 2007 17:08:18 -0700
> 
>> Anyone know the reasoning for masking out the PROMISC flag
>> in dev_get_flags() ?
> 
> Because promiscuous status is a counter, not a binary
> on-off state.
> 
> You can't expect to just clear it and expect all the
> other promiscuous users to just "go away" and be ok
> with the device leaving promiscuous mode.

Yes, I understand why you wouldn't let a user set promisc in this
manner.

> Since you can't sanely "set" it, we don't provide it
> either.

What harm is there letting the user know if their hardware is PROMISC
or not, regardless of how it got that way?

Also, it seems you *can* at least turn it on with ifconfig, and
you can decrement at least once with ifconfig as well.  If nothing
else has promiscuity set, then this will indeed toggle the state, right?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

