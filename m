From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/9] statistics improvements
Date: Sat, 12 Jan 2008 21:33:16 -0800
Message-ID: <4789A29C.6080000@linux-foundation.org>
References: <20080112064513.803976049@linux-foundation.org>	<20080112064646.282104074@linux-foundation.org> <20080112.205520.55747078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48817 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751127AbYAMFdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:33:32 -0500
In-Reply-To: <20080112.205520.55747078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 11 Jan 2008 22:45:17 -0800
>
>   
>> Turn the unused size field into a useful counter for the number
>> of routes.
>>
>> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
>>     
>
> It's not useful if nothing reports it's value.  I'm dropping
> this.
>
> Unless you add code to provide this information via procfs
> or similar, better to just remove it.
>   
The size field is added to /proc/net/fib_triestat that was the point.
