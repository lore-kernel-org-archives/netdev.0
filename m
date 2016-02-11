From: Brian Russell <brian.russell@brocade.com>
Subject: Re: [PATCH net-next 1/2] nsh: encapsulation module
Date: Thu, 11 Feb 2016 19:54:51 +0000
Message-ID: <56BCE70B.10901@brocade.com>
References: <1455186914-8952-1-git-send-email-brussell@brocade.com>
 <1455186914-8952-3-git-send-email-brussell@brocade.com>
 <20160211.113946.1731145198917250643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:7316 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980AbcBKTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 14:55:04 -0500
In-Reply-To: <20160211.113946.1731145198917250643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/02/16 16:39, David Miller wrote:
> From: Brian Russell <brussell@brocade.com>
> Date: Thu, 11 Feb 2016 10:35:13 +0000
> 
>> +++ b/include/net/nsh.h
>> +struct nsh_metadata {
>> +	u_short class;
>> +	u_char crit;
>> +	u_char type;
>> +	u_int len;  /* 4 byte words */
>> +	void *data;
> 
> Do not use these shorthands, spell out "unsigned short" etc. explicitly.
> 
> But in these cases you should be using fixed sized types like "u16".
> 
> Also, in a header file such as this one which is private to the kernel
> you should be using the variants of these types without the leading underscores.
> 

Ok, will fix those up.

Thanks,

Brian
