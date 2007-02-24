From: LDB <thesource@ldb-jab.org>
Subject: Re: Copy data from one SKB to another
Date: Sat, 24 Feb 2007 05:53:51 -0500
Message-ID: <45E0193F.5090909@ldb-jab.org>
References: <58989.129.240.228.53.1172145587.squirrel@webmail.uio.no> <e92e3a770702240137p6c0b31b3r2b7ce0b4042fac4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "kristrev@student.matnat.uio.no" <kristrev@student.matnat.uio.no>,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
To: kalash nainwal <nirvana.code@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ldb-jab.org ([209.135.157.157]:46969 "EHLO
	master.ldb-jab.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932677AbXBXLOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 06:14:02 -0500
In-Reply-To: <e92e3a770702240137p6c0b31b3r2b7ce0b4042fac4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kalash nainwal wrote:
> On 2/22/07, kristrev@student.matnat.uio.no
> <kristrev@student.matnat.uio.no> wrote:
>> Hello,
>>
>> I am working on optimizing the TCP-code for a certain type of TCP-stream,
>> and to make one of my optimizations work I need to copy data from one SKB
>> (the data field of the skb) to another SKB (data field).
>>
>> Currently I am using memcpy, and it does what it is supposed to, but I am
>> curious as to if there are any other (potentially faster/more efficient)
>> ways of doing it. I have checked out the skb_add_data (used when you can
>> copy data from the msg you are sending into the most recent skb added to
>> the queue), but from what I can understand it only copies from userspace
>> into kernelspace (whereas I need to copy kernel-kernel).
>>
>> Does anyone have any hints, suggestions, solutions or something else they
>> think might help?
>>
>> Thanks,
>> Kristian
>>
>> -
> 
> How about cloning? Is that an option?
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

skb_clone is an option but you cannot modify any data - correct me if I am wrong.

The other options are pskb_copy and skb_copy used when modifications are
necessary - correct if I am wrong.

You just have to chose which is appropriate for your specific needs.

LDB
