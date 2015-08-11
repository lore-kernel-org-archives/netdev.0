From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] documentation: bring vxlan documentation more
 up-to-date
Date: Tue, 11 Aug 2015 15:18:54 -0700
Message-ID: <55CA74CE.3000704@hp.com>
References: <20150811204716.79B2C29004D1@tardy> <20150811150957.78de9c33@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:55862 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbbHKWS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 18:18:56 -0400
In-Reply-To: <20150811150957.78de9c33@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2015 03:09 PM, Stephen Hemminger wrote:
> On Tue, 11 Aug 2015 13:47:16 -0700 (PDT)
> raj@tardy.usa.hp.com (Rick Jones) wrote:
>
>> +  # ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth1
>> +
>> +This creates a new device named vxlan0.  The device uses the
>> +multicast group 239.1.1.1 over eth1 to handle traffic for which there
>> +is no entry is in the forwarding table.  The Linux implementation of
>> +VXLAN pre-dates the IANA's selection of a standard destination port
>> +number and uses the Linux-selected value by default to maintain
>> +backwards compatibility.  If you wish to use the IANA-assigned
>> +destination port number of 4789 you can add "dstport 4789" to the
>> +command line above.
>
> This example should be changed to use "dstport 4789".
> Almost anyone reading the documentation will want to use the IANA value.

I'll spin a v2.

> Note: ip command will give a noisy warning if dstport is not set.

Indeed. It was that noisy warning which sent me down this path in the 
first place :)

rick jones
