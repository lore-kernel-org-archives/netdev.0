From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 04:11:42 -0400
Message-ID: <4AC9AA3E.2090001@gmail.com>
References: <4AC79905.1030904@gmail.com> <20091005.002719.146534039.davem@davemloft.net> <4AC9A714.7060903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:42923 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbZJEIMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 04:12:22 -0400
Received: by ywh3 with SMTP id 3so2725131ywh.22
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 01:11:45 -0700 (PDT)
In-Reply-To: <4AC9A714.7060903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> David Miller wrote:
>> struct tcp_sock is already WAY TOO BIG on 64-bit systems, adding 20
>> more bytes to it for some odd-ball feature is not something I'm
>> willing to do, sorry.
>>
> I see we're cross-posting at the same time....  Since in your previous
> review (last year) this issue was not mentioned, is there some other
> data organization that you would suggest?
> 
> http://article.gmane.org/gmane.linux.network/102779
> 
>   "This looks mostly fine to me.  I would even advocate not using a config
>    option for this."
> 
As a quick followup, I wish this had been raised in my previous posting,
where I'd given the headers, for exactly this kind of feedback. :-)

Given that size is now a concern, would a single kref pointer with a u16
field for flags be acceptable?  I could bury the rest in the kref block.

Would that be acceptable without a config option?
