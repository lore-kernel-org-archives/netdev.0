From: Rick Jones <rick.jones2@hp.com>
Subject: Re: write() udp socket
Date: Mon, 25 Jul 2011 10:38:12 -0700
Message-ID: <4E2DAA04.2070205@hp.com>
References: <tencent_287F494544728EDB6DA9C8ED@qq.com> <CA+v9cxZAF27mXc6aCEPyOdqbeLved3_xibvDS4TQugHR=7owPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ZHOU Xiaobo <xb.zhou@qq.com>, netdev <netdev@vger.kernel.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:43950 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab1GYRiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 13:38:13 -0400
In-Reply-To: <CA+v9cxZAF27mXc6aCEPyOdqbeLved3_xibvDS4TQugHR=7owPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2011 01:33 AM, Huajun Li wrote:
> 2011/7/23 ZHOU Xiaobo<xb.zhou@qq.com>:
>> question No1:
>> When I call
>> ssize_t write(int fd, const void *buf, size_t count);
>>
>>
>> on a nonblocking UDP socket, is the return value  always equal to 'count'?
>>
>>
>
> I don't think so.  The function may be interrupt by signal or return
> due to other reason, so the return value only represents the size it
> writes successfully to the fd.

I believe it should either appaear to succeed or fail.  write() best not 
be sending partial UDP datagrams.  That would be "bad."
