From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Wed, 01 Dec 2010 11:42:11 -0800
Message-ID: <4CF6A513.4030400@hp.com>
References: <20101130135549.GA22688@verge.net.au> <4CF53AB2.60209@hp.com> <20101201043017.GA3485@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:40781 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756498Ab0LATmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:42:14 -0500
In-Reply-To: <20101201043017.GA3485@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>You are in a maze of twisty heuristics and algorithms, all
>>interacting :)  If there are only three links in the bond, I suspect
>>the chances for spurrious fast retransmission are somewhat smaller
>>than if you had say four, based on just hand-waving on three
>>duplicate ACKs requires receipt of perhaps four out of order
>>segments.
> 
> 
> Unfortunately NIC/slot availability only stretches to three links :-(
> If you think its really worthwhile I can obtain some more dual-port nics.

Only if you want to increase the chances of reordering that triggers spurrious 
fast retransmits.

rick jones
