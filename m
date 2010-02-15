From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Mon, 15 Feb 2010 09:05:42 -0800
Message-ID: <4B797EE6.8070203@us.ibm.com>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com> <201002131834.00612.arnd@arndb.de> <4B7711C9.2090800@us.ibm.com> <201002142013.08745.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:40257 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab0BORGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 12:06:06 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1FH2bVl004747
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 10:02:37 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1FH5owA082282
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 10:05:54 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1FH5n3d028259
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 10:05:49 -0700
In-Reply-To: <201002142013.08745.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/14/2010 11:13 AM, Arnd Bergmann wrote:
> On Saturday 13 February 2010 21:55:37 Sridhar Samudrala wrote:
>    
>>> Also, what about IFF_TAP and IFF_NO_PI, should those be always set?
>>>
>>>        
>> Atleast it is not required for qemu to have these flags set. If we are
>> not doing anything different based on
>> these flags, i felt we don't need to have them.
>>      
> The point is that other applications might depend on them. We only support
> IFF_TAP operation (not IFF_TUN), and we do not understand the !IFF_NO_PI
> frame format, so any program that tries to use the PI header or use cooked
> IP packets will get incorrect data.
>
>    
OK. that is a good point. We should handle cases where a user is trying 
to set IFF_TUN and !IFF_NO_PI.

Thanks
Sridhar

