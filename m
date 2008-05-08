From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH] [2.6.26] [CAN] Fix can_send() handling on dev_queue_xmit()
 failures
Date: Thu, 08 May 2008 19:00:39 +0200
Message-ID: <482331B7.909@hartkopp.net>
References: <4820B665.6070609@hartkopp.net> <20080508.025044.124227730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, Sam Ravnborg <sam@ravnborg.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:10058 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762365AbYEHRAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 13:00:42 -0400
In-Reply-To: <20080508.025044.124227730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>
>> this patch should go into 2.6.26 and also applies fine on 2.6.25.1.
>>
>> IMO this issue is not that 'critical' that it *requires* to become
>> part of 2.6.25.2. Please forward the patch to Greg at your own opinion.
>>     
>
> I think I'll push it to -stable, thanks.
>
>   

Thanks!

Maybe we should also consider to push the patch from Sam regarding the 
wrong copy_from_user() results interpretation to the stable tree:

can: Fix copy_from_user() results interpretation

author 	Sam Ravnborg <sam@ravnborg.org>

	Sun, 27 Apr 2008 05:57:25 +0000 (22:57 -0700)
committer 	David S. Miller <davem@davemloft.net>

	Sun, 27 Apr 2008 21:26:51 +0000 (14:26 -0700)
commit 	3f91bd420a955803421f2db17b2e04aacfbb2bb8



Regards,
Oliver



