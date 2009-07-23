From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] be2net: Adding support for 802.1ad (q-in-q mode)
Date: Thu, 23 Jul 2009 12:12:56 +0200
Message-ID: <4A6837A8.9040208@trash.net>
References: <20090723082552.GA602@serverengines.com> <4A6823B5.7050608@trash.net> <20090723090216.GA1761@serverengines.com> <4A68284B.8020100@trash.net> <20090723092036.GB1761@serverengines.com> <4A682CA1.8030706@trash.net> <20090723094501.GA3172@serverengines.com> <4A6831E7.3020302@trash.net> <20090723100533.GB3172@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbZGWKM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 06:12:58 -0400
In-Reply-To: <20090723100533.GB3172@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sarveshwar Bandi wrote:
> On 23/07/09 11:48 +0200, Patrick McHardy wrote:
>> Sarveshwar Bandi wrote:
>>> On 23/07/09 11:25 +0200, Patrick McHardy wrote:
>>>> adapter->vlan_grp will always be the VLAN group associated directly with
>>>> the device, which is the group for the outer tag, not the inner one. So
>>>> this can't properly associate packets with the correct VLAN device.
>>>>
>>> In this case, vid is the inner vlan id in the packet. This is also the
>>> vlan id configured by vconfig. 
>>
>> So where does the outer tag come from then? Please provide an example
>> how to configure this using Q-in-Q.
>>
> The outer vlan is totally transparent to the host. It is used by the NIC 
> to demux packets across multiple pci network functions. Currently the 
> outer vlan tags are configured on the NIC by OEM provided utilities.

I see. A proper changelog entry would have explained that and avoided
all this confusion. Not that I think using another tool for this is a
good solution, but no objections from a functional POV.

