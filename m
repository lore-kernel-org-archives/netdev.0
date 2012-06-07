From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Wed, 06 Jun 2012 17:26:40 -0700
Message-ID: <4FCFF540.5010608@candelatech.com>
References: <4FCCFE76.3060304@candelatech.com> <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51444 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488Ab2FGA0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 20:26:44 -0400
In-Reply-To: <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2012 12:22 PM, Daniel Baluta wrote:

> Currently, there is no way to tune these parameters. Here is an experimental
> patch [1]. If anyone, thinks that this patch has a chance to get accepted
> I will be happily try to further improve it.
>
>>
>> Packet traces and other info available if anyone wants to take a look.
>
> thanks,
> Daniel.
>
> [1] http://marc.info/?l=linux-netdev&m=131983649130350&w=2

I tried your patch in 3.5.0-rc1.

Doesn't seem to help any...do you have suggested settings for
the proc values?  (I tried increasing tcp_delack_segs up to 10,
but no significant increase...)

I'll keep poking around.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
