From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] iptables: =?UTF-8?Q?xt=5Frecent=3A=20Add=20optional?=
 =?UTF-8?Q?=20mask=20option=20for=20xt=5Frecent?=
Date: Sat, 14 Jul 2012 20:55:57 +0300
Message-ID: <a2feae54d7bd12b00614e679fd2fd4a9@visp.net.lb>
References: <1337285337-13619-1-git-send-email-denys@visp.net.lb>
 <20120714150527.GA6271@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netfilter-devel@vger.kernel.org>,
	Linux netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43889 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab2GNR4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 13:56:01 -0400
In-Reply-To: <20120714150527.GA6271@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo

On 2012-07-14 18:05, Pablo Neira Ayuso wrote:
> Hi Denys,
>
> On Thu, May 17, 2012 at 11:08:57PM +0300, Denys Fedoryshchenko wrote:
>> Use case for this feature:
>> 1)In some occasions if you need to allow,block,match specific 
>> subnet.
>> 2)I can use recent as a trigger when netfilter rule matches, with 
>> mask 0.0.0.0
>>
>> Tested for backward compatibility:
>> )old (userspace) iptables, new kernel
>> )old kernel, new iptables
>> )new kernel, new iptables
>
> I've cleaned up this patch:
>
> 
> http://git.netfilter.org/cgi-bin/gitweb.cgi?p=iptables.git;a=commit;h=73bf03981dfaee48ac1d6da380d46501a96cc83e
>
> It's not yet in master. Please, check that this is correct.
>
> BTW, the man page update is still missing.

Thank you, everything looks ok, i will try to diff(to learn, not repeat 
coding style mistakes in next submissions) and test. Since i'm in desert 
now, it will take few days.
I will prepare also man page patch for iptables.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
