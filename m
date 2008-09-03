From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] bridge: STP timer management range checking
Date: Tue, 02 Sep 2008 17:00:40 -0700
Message-ID: <48BDD3A8.6070500@hp.com>
References: <48BB295A.6050200@vyatta.com>	<20080901093827.24eec86f@lxorguk.ukuu.org.uk>	<48BD6C8E.5060704@hp.com> <20080902.164130.156055373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, stephen.hemminger@vyatta.com,
	shemminger@vyatta.com, dusanc@gmail.com, romieu@fr.zoreil.com,
	hancockr@shaw.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:3369 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbYICAAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:00:47 -0400
In-Reply-To: <20080902.164130.156055373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 02 Sep 2008 09:40:46 -0700
>>Can one change the TCP maximum RTO to be smaller than specified in the specs? 
> We always min-clamp the RTO at RTO calculation time in order to be
> compatible with BSD's coarse grained times.

But tuning TCP_RTO_MAX isn't permitted right?  I'm drawing (perhaps 
flawed) parallels/distinctions between what is/isn't permitted to tweak 
for timers for one protocol versus another and wondering which may be a 
case of sauce for the goose/gander.

rick jones
