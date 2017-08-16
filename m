From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [patch] netlink.7: srcfix Change buffer size in example code
 about reading netlink message.
Date: Wed, 16 Aug 2017 02:40:09 +0200
Message-ID: <30f1a7e1-707a-b8b1-7414-2f97a79ac372@gmail.com>
References: <e9409957290af5249750afa0f10de3a6@linux.vnet.ibm.com>
 <7f6d8b0b-6f29-37af-9b25-47a2e78a31fd@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>, dwilder <dwilder@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37436 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753544AbdHPAkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:40:16 -0400
In-Reply-To: <7f6d8b0b-6f29-37af-9b25-47a2e78a31fd@hpe.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 11:36 PM, Rick Jones wrote:
>> Lets change the example so others don't propagate the problem further.
>>
>> Signed-off-by David Wilder <dwilder@us.ibm.com>
>>
>> --- man7/netlink.7.orig 2016-11-14 13:30:36.522101156 -0800
>> +++ man7/netlink.7      2016-11-14 13:30:51.002086354 -0800
>> @@ -511,7 +511,7 @@
>>  .in +4n
>>  .nf
>>  int len;
>> -char buf[4096];
>> +char buf[8192];
> 
> Since there doesn't seem to be a define one could use in the user space 
> linux/netlink.h (?), but there are comments in the example code in the 
> manpage, how about also including a brief comment to the effect that 
> using 8192 bytes will avoid message truncation problems on platforms 
> with a large PAGE_SIZE?
> 
> /* avoid msg truncation on > 4096 byte PAGE_SIZE platforms */
> 
> or something like that.

Thanks for the suggestion, Rick. Done!

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
