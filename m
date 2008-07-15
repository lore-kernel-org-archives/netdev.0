From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/14]: Make packet scheduler multiqueue aware.
Date: Tue, 15 Jul 2008 04:08:13 +0200
Message-ID: <487C068D.3060002@trash.net>
References: <20080714.155908.174564017.davem@davemloft.net>	<487BEE7C.6080300@trash.net> <20080714.184849.121429019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39941 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbYGOCNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 22:13:51 -0400
In-Reply-To: <20080714.184849.121429019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 15 Jul 2008 02:25:32 +0200
>
>   
>> Unfortunately that seems to imply that anything but the really
>> simple qdiscs can't be used transparently in combination with
>> multiqueue without breaking configurations.
>>     
>
> I think we can fix this after the merge window :)
>   
Yes, that shouldn't be a problem.
>
> One idea is to allow all of the queues to point at a
> single qdisc.  We'd just need to work out how to do the
> locking.
>
> For example, the Qdisc has a lock member, and a pointer.
> For simple qdiscs the pointer points at the netdev_queue
> lock.  But when sharing, we use the in-Qdisc static lock
That sounds nice and easy.

