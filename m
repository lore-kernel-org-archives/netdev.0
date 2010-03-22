From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Mon, 22 Mar 2010 16:38:02 +0100
Message-ID: <4BA78EDA.8020003@trash.net>
References: <4BA25C82.7000301@netfilter.org>	<4BA26138.6070709@trash.net>	<4BA2C44A.1000100@netfilter.org> <20100320.143027.116368032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37837 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168Ab0CVPiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 11:38:07 -0400
In-Reply-To: <20100320.143027.116368032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Fri, 19 Mar 2010 01:24:42 +0100
>
>   
>> Patrick McHardy wrote:
>>     
>>> Generally the logic seems inverted, you should return an error
>>> to conntrack if userspace wasn't notified of the error.
>>>       
>> Indeed, thanks. Are you OK with this patch instead?
>>     
>
> I went over all of this and now the patches #1 and #2 look
> correct to me, so I've applied them to net-2.6
>
> Patrick let me know if you think any follow-on tidy ups
> are still necessary and we can add them.
The patch looks fine to me as well, thanks Dave.
