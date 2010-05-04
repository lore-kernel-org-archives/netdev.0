From: enh <enh@google.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 4 May 2010 15:26:52 -0700
Message-ID: <AANLkTilPHlQ-CDSWnUn52al5DJfRxuZ8eiXwf3ep5LUD@mail.gmail.com>
References: <OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>
	 <20100504.005757.97355845.davem@davemloft.net>
	 <4BE031FA.6040006@hp.com>
	 <20100504.144647.157477097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: brian.haley@hp.com, dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:40579 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933432Ab0EDW0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 18:26:54 -0400
In-Reply-To: <20100504.144647.157477097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 4, 2010 at 14:46, David Miller <davem@davemloft.net> wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Tue, 04 May 2010 10:40:58 -0400
>
>> Specifying -1 for setsockopt(IPV6_MULTICAST_HOPS) should set the socket
>> value back to the system default value of IPV6_DEFAULT_MCASTHOPS (1).
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>
> In cast it wasn't clear from my other reply, I'm not applying this
> patch because I intentionally left this behavior there based upon
> some comments from Elliot in that this lets developers get the
> old default by asking for "-1" explicitly with a setsockopt.

(for the record, i don't need that behavior myself, and have no
opinion on whether or not it makes sense for you guys... i'll only
ever call setsockopt with 0 <= value <= 255. all i need is for the
default when i never call setsockopt to be 1. for now, i've added a
work-around where i explicitly call setsockopt with 1 when i create
the socket.)

-- 
Elliott Hughes - http://who/enh - http://jessies.org/~enh/
