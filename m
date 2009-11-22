From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement socket
 option TCP_COOKIE_TRANSACTIONS
Date: Sun, 22 Nov 2009 01:25:43 -0500
Message-ID: <4B08D967.80003@gmail.com>
References: <4B06A1FF.8000202@gmail.com>	<4B06AC2C.3070102@gmail.com> <20091120.092651.254794724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:37419 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbZKVGbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2009 01:31:35 -0500
Received: by yxe17 with SMTP id 17so3970090yxe.33
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 22:31:41 -0800 (PST)
In-Reply-To: <20091120.092651.254794724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Fri, 20 Nov 2009 09:48:12 -0500
>> +		if (ctd.tcpct_used > 0
>> +		 || (tp->cookie_values == NULL
>> +		  && (sysctl_tcp_cookie_size > 0
>> +		   || ctd.tcpct_cookie_desired > 0
>> +		   || ctd.tcpct_s_data_desired > 0))) {
> 
> Please fix the conditional coding style, and the alignment of
> the lines, it's not right here.
> 
Eliding the repeated assertions, and focusing on this example.
This is not addressed (nor forbidden) in CodingStyle.

As Joe noted earlier with '?' and ':', there are ample examples
throughout the code base of this style, including here and there
among the tcp*.c files.  Obviously, this is very easy to read!

     Coding style is all about readability and maintainability
     using commonly available tools.

However, grep shows that the "||" or "&&" is elsewhere most often
indented 4 for each level (although there is some inconsistency).
Either 1, 2, or 4 distinguishes <condition> indentation from
<statements> indented by tab (8).

In my experience, I've found 1 best, as that lines up variables
and parentheses levels, and it's easy to type.  But it certainly
would be easy enough to indent by 2 or 4 instead.

BTW, the 'indent' program turns this into incomprehensible and
unmaintainable garbage.  Of course, there are ample examples of
garbage in these tcp*.c files, too.... :-(

Therefore, David, would indentation of 2 or 4 be preferable here?
