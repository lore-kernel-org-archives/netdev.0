From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: ixgbe question
Date: Mon, 30 Nov 2009 12:20:15 -0800
Message-ID: <4B1428FF.9010100@intel.com>
References: <4B0BADA6.7080602@gmail.com>	<1259057164.2631.36.camel@ppwaskie-mobl2>	<4B0BDC24.1060401@intel.com> <20091129.001856.236847721.davem@davemloft.net> <4B13C250.7020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"robert@herjulf.net" <robert@herjulf.net>,
	"hawk@diku.dk" <hawk@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37917 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbZK3UUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 15:20:10 -0500
In-Reply-To: <4B13C250.7020402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> David Miller a =E9crit :
>  =20
>> From: John Fastabend <john.r.fastabend@intel.com>
>> Date: Tue, 24 Nov 2009 13:14:12 +0000
>>
>>    =20
>>> Believe the below patch will break DCB and FCoE though, both featur=
es
>>> have the potential to set real_num_tx_queues to greater then the
>>> number of CPUs.  This could result in real_num_tx_queues >
>>> num_tx_queues.
>>>
>>> The current solution isn't that great though, maybe we should set t=
o
>>> the minimum of MAX_TX_QUEUES and num_possible_cpus() * 2 + 8.
>>>
>>> That should cover the maximum possible queues for DCB, FCoE and the=
ir
>>> combinations.
>>>
>>> general multiq =3D num_possible_cpus()
>>> DCB =3D 8 tx queue's
>>> FCoE =3D 2*num_possible_cpus()
>>> FCoE + DCB =3D 8 tx queues + num_possible_cpus
>>>      =20
>> Eric, I'm tossing your patch because of this problem, just FYI.
>>    =20
>
> Sure, I guess we need a more generic way to handle this.
>
>  =20
Eric,

I'll resubmit your patch with a small update to fix my concerns soon.

thanks,
john.
