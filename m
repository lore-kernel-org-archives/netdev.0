From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH] [2.6.26] [CAN] Fix can_send() handling on dev_queue_xmit()
 failures
Date: Thu, 08 May 2008 20:27:49 +0200
Message-ID: <48234625.5020706@hartkopp.net>
References: <4820B665.6070609@hartkopp.net> <20080508.025044.124227730.davem@davemloft.net> <482331B7.909@hartkopp.net> <20080508172938.GA7461@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, David Miller <davem@davemloft.net>,
	urs@isnogud.escape.de, netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:19223 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbYEHS1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 14:27:52 -0400
In-Reply-To: <20080508172938.GA7461@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
> On Thu, May 08, 2008 at 07:00:39PM +0200, Oliver Hartkopp wrote:
>   
>>
>>
>> Maybe we should also consider to push the patch from Sam regarding the 
>> wrong copy_from_user() results interpretation to the stable tree:
>>
>> can: Fix copy_from_user() results interpretation
>>
>> author 	Sam Ravnborg <sam@ravnborg.org>
>>
>> 	Sun, 27 Apr 2008 05:57:25 +0000 (22:57 -0700)
>> committer 	David S. Miller <davem@davemloft.net>
>>
>> 	Sun, 27 Apr 2008 21:26:51 +0000 (14:26 -0700)
>> commit 	3f91bd420a955803421f2db17b2e04aacfbb2bb8
>>     
>
> I recall tat I considered stable material when I did
> this patch. But as I merely just did a codingstyle update
> of the old patch I dropped it.
>
> But looks like possible -stable materail so I've added
> stable@kernel.org to the to list so they can judge.
>   

Yep. Thanks.

Indeed you updated the codingstyle from a patch suggested by Pavel - but 
his (original) patch fixes the copy_from_user() result interpretation. 
So it was not only a codingstyle patch which was commited here.

Best regards,
Oliver

