From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next 1/2] ipv4: ip_tunnel: use net namespace from
 rtable not socket
Date: Wed, 08 Apr 2015 10:31:06 -0700
Message-ID: <552565DA.5010606@hp.com>
References: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org> <20150408.120958.1217271670558706137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:33179 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbbDHRbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:31:08 -0400
In-Reply-To: <20150408.120958.1217271670558706137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 09:09 AM, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed,  8 Apr 2015 17:01:22 +0200
>
>> The socket parameter might legally be NULL, thus sock_net is sometimes
>> causing a NULL pointer dereference. Using net_device pointer in dst_entry
>> is more reliable.
>>
>> Fixes: b6a7719aedd7e5c ("ipv4: hash net ptr into fragmentation bucket selection")
>> Reported-by: Rick Jones <rick.jones2@hp.com>
>> Cc: Rick Jones <rick.jones2@hp.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Applied.

Horses, barn doors, crossed i's and dotted t's but I can report that 
with that in place the problem I reported in "VxLAN system wedge in 
4.0.0-rc5+ from davem net-next?" no longer happens.

rick
