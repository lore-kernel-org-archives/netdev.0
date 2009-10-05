From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 03:58:12 -0400
Message-ID: <4AC9A714.7060903@gmail.com>
References: <4AC79905.1030904@gmail.com> <20091005.002719.146534039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:47327 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758426AbZJEH6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:58:53 -0400
Received: by ywh3 with SMTP id 3so2717342ywh.22
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 00:58:16 -0700 (PDT)
In-Reply-To: <20091005.002719.146534039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Sat, 03 Oct 2009 14:33:41 -0400
> 
>> @@ -406,6 +454,32 @@ struct tcp_sock {
>  ...
>> +	struct tcp_s_data_payload	*s_data_payload;
>  ...
>> +	struct tcp_cookie_pair	  	*cookie_pair;
>  ...
>> +	u16				s_data_desired;	/* bytes */
>  ...
>> +	u8				cookie_desired;	/* bytes */
>> +	u8				s_data_in:1,
>> +					s_data_out:1,
>> +					cookie_in_always:1,
>> +					cookie_out_never:1;
> 
> struct tcp_sock is already WAY TOO BIG on 64-bit systems, adding 20
> more bytes to it for some odd-ball feature is not something I'm
> willing to do, sorry.
> 
I see we're cross-posting at the same time....  Since in your previous
review (last year) this issue was not mentioned, is there some other
data organization that you would suggest?

http://article.gmane.org/gmane.linux.network/102779

   "This looks mostly fine to me.  I would even advocate not using a config
    option for this."

Perhaps you would prefer this as a config option after all?

As for "odd-ball feature", of course this is the initial pass on a much
larger project....

