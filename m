From: Ying Xue <ying.xue@windriver.com>
Subject: Re: netns refcount leak
Date: Mon, 9 Mar 2015 17:50:28 +0800
Message-ID: <54FD6CE4.5040708@windriver.com>
References: <CAHA+R7PyGGjx_L_fMnBbTf8tgttqrH1d4LvLKR=CFB82CERoEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:54089 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbbCIJul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:50:41 -0400
In-Reply-To: <CAHA+R7PyGGjx_L_fMnBbTf8tgttqrH1d4LvLKR=CFB82CERoEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2015 07:29 AM, Cong Wang wrote:
> Hi, Ying
> 
> 
> The following commit from you causes a netns refcount leak:
> 
> a62fbccecd62bacb4416fc427239f5b43b25d05e is the first bad commit
> commit a62fbccecd62bacb4416fc427239f5b43b25d05e
> Author: Ying Xue <ying.xue@windriver.com>
> Date:   Fri Jan 9 15:27:11 2015 +0800
> 
>     tipc: make subscriber server support net namespace
> 
>     TIPC establishes one subscriber server which allows users to subscribe
>     their interesting name service status. After tipc supports namespace,
>     one dedicated tipc stack instance is created for each namespace, and
>     each instance can be deemed as one independent TIPC node. As a result,
>     subscriber server must be built for each namespace.
> 
>     Signed-off-by: Ying Xue <ying.xue@windriver.com>
>     Tested-by: Tero Aho <Tero.Aho@coriant.com>
>     Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
> which prevents a netns being removed if I enable TIPC.
> 
> I am not familiar with TIPC code, please take a look.
> 

Thank you for the report! I will investigate it, so please wait a moment.

Regards,
Ying

> Thanks!
> 
> 
