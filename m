From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 06 Jan 2010 09:21:49 -0800
Message-ID: <4B44C6AD.6040806@hp.com>
References: <20100105.163911.10233438.davem@davemloft.net>	<20100106020756.GA4378@localhost.localdomain> <20100105.195953.16499086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:11805 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706Ab0AFRVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 12:21:53 -0500
In-Reply-To: <20100105.195953.16499086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 5 Jan 2010 21:07:56 -0500
> 
> 
>>Dave, If that patch fixes the problem (waiting on test results now,
>>but I figure it will), what if we add a parameter to tcp_sequence
>>(and tcp_validate_incomming), that represents an offset to trim from
>>end_seq (so that we can effectively ignore the garbage byte)?
> 
> 
> Sure, we could do that too, and it would be an improvement.
> 
> Let's first wait for test results and also give a bit for
> others to potentially come up with implementation ideas.

Might it suffice to simply enable TCP keepalives on the Linux end?  Or is that 
too big a kludge?

rick jones
