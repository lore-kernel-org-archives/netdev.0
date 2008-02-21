From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Don't create tunnels with '%' in name.
Date: Thu, 21 Feb 2008 13:22:01 +0100
Message-ID: <47BD6CE9.7000908@trash.net>
References: <47BD6907.7050303@openvz.org> <47BD6A28.1030007@trash.net> <47BD6BD7.1060200@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:56349 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753614AbYBUMWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 07:22:21 -0500
In-Reply-To: <47BD6BD7.1060200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Patrick McHardy wrote:
>
>> It would be nicer to replace the entire hand-made name
>> allocation to remove the 100 device limit.
>>
> 
> Actually, I thought the same, but fixing % in names looks like a 
> BUG-fix for 2.6.25, while removing the hand-made name allocation 
> looks like an enhancement for 2.6.26. No?


Well, its so closely related that I guess it would still look
like a bugfix :) But changing this in 2.6.26 is also fine of
course, your patch just reminded me since I wanted to change
this for a long time and repeatedly forgot about it again.

