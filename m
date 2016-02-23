From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 09:20:25 -0800
Message-ID: <56CC94D9.4030308@hpe.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
 <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
 <CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
 <56CC7848.2000704@solarflare.com>
 <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@kernel.org>, Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>,
	Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:35760 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbcBWRU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 12:20:28 -0500
In-Reply-To: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 08:47 AM, Tom Herbert wrote:
> Right, GRO should probably not coalesce packets with non-zero IP
> identifiers due to the loss of information. Besides that, RFC6848 says
> the IP identifier should only be set for fragmentation anyway so there
> shouldn't be any issue and really no need for HW TSO (or LRO) to
> support that.

You sure that is RFC 6848 "Specifying Civic Address Extensions in the 
Presence Information Data Format Location Object (PIDF-LO)" ?

In whichever RFC that may be, is it a SHOULD or a MUST, and just how 
many "other" stacks might be setting a non-zero IP ID on fragments with 
DF set?

rick jones

> We need to do increment IP identifier in UFO, but I only see one
> device (neterion) that advertises NETIF_F_UFO-- honestly, removing
> that feature might be another good simplification!
>
> Tom
>
>> --
>> -Ed
