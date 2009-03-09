From: Ben Greear <greearb@candelatech.com>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces?
Date: Mon, 09 Mar 2009 11:58:39 -0700
Message-ID: <49B566DF.3040603@candelatech.com>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>	<49B52F73.7010508@trash.net> <m13admbsuk.fsf@fess.ebiederm.org>	<49B53B6C.7060400@trash.net> <m1fxhm8xl1.fsf@fess.ebiederm.org> <49B5478C.4020001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:32809 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbZCIS6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 14:58:50 -0400
In-Reply-To: <49B5478C.4020001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

>> Now that I think about it we could call ndo_start_xmit directly
>> from the macvlan code, and bypass whatever hook we use to
>> intercept packets going out the normal device it should not
>> be too difficult.
> 
> We don't intercept packets on TX, they have to be explicitly delivered
> to macvlan.

It might suck for performance, but mac-vlan could register an 'ALL' protocol
on the physical dev, similar to tcp-dump, to grab pkts on tx and pass the
ones it cares about back up to the vlans?

I'd want run-time control to disable any of these costly options for those that
don't need it, however.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

