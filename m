From: Patrick McHardy <kaber@trash.net>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 13:54:28 +0100
Message-ID: <49085D04.1060009@trash.net>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net>	 <49083825.3000601@trash.net> <3400f2f60810290551y39c61e0aj90ca1222b339798c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Ramon Casellas <ramon.casellas@cttc.es>
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65225 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754229AbYJ2Myc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 08:54:32 -0400
In-Reply-To: <3400f2f60810290551y39c61e0aj90ca1222b339798c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J. K. Cliburn wrote:
> [adding bug reporter to cc list]
> 
> On Wed, Oct 29, 2008 at 5:17 AM, Patrick McHardy <kaber@trash.net> wrote:
>> This is the best I could come up with, short of simply restoring
>> the old behaviour for non-polling drivers.
>>
>> The __vlan_hwaccel_rx function only does the device lookup and
>> stores it in the cb. The remaining processing is done in a new
>> function that is invoked by netif_receive_skb(), in the proper
>> context. Unfortunatly this needs vlan-specific handling in
>> netif_receive_skb().
>>
> 
> Thanks Jarek and Patrick.
> 
> Ramon,
> 
> Can you please try the attached patch from Patrick and see if it fixes
> your kernel warning?

Just to make sure we don't run into testing mistakes -
the ethernet device needs to have tcpdump or something
similar running to trigger this warning.


