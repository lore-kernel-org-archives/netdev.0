From: Zacco <zacco@fw.hu>
Subject: Re: many sockets, slow sendto
Date: Tue, 06 Mar 2007 22:28:02 +0100
Message-ID: <45EDDCE2.9060609@fw.hu>
References: <E1HObHK-0000WB-00@osiris.swi.hu> <p73bqj6b2gk.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>, baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta02.mail.t-online.hu ([195.228.240.51]:52108 "EHLO
	mta02.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965149AbXCFV2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:28:05 -0500
In-Reply-To: <p73bqj6b2gk.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thx a lot you for the advice, I'll have a try.
And sorry for the stupid webmail, I will not use it again.

Zacco


Andi Kleen wrote:
> Zaccomer Lajos <zacco@fw.hu> writes:
>
>   
>> I'm playing around with a simulation, in which many thousands of IP
>>
>> addresses (on interface aliases) are used to send/receive TCP/UDP
>>     
>
> Something seems to be wrong with your emailer. It adds a empty
> line between each real line.
>
>   
>> packets. I noticed that the time of send/sendto increased linearly
>>
>> with the number of file descriptors, and I found it rather strange.
>>     
>
> Yes that is strange. I would suggest you use oprofile to identify which
> parts of the kernel use the CPU time with many descriptors.
>
> -Andi
>
>   

