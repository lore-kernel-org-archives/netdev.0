From: "\"G\"" <balajig81@gmail.com>
Subject: Re: Kernel Support in Linux PPC
Date: Tue, 26 Aug 2008 21:26:51 +0530
Message-ID: <6dd1343e0808260856tc71a874vcc0e1889588edb4b@mail.gmail.com>
References: <6dd1343e0808260834h7bc423a9ka47446111cbdb01f@mail.gmail.com>
	 <379e30200808260848n4cf2a58r299728066b531b58@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Tobias Koeck" <tobias.koeck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:18145 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848AbYHZP4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 11:56:54 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1325602tic.23
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 08:56:52 -0700 (PDT)
In-Reply-To: <379e30200808260848n4cf2a58r299728066b531b58@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

> have you used the ntohl (and similar) conversion methods?

Yeah exactly i ve used it but apart from that will there be any big
surprises as such when i migrate it to PPC with the latest (2.6.26)
kernel ?

Sorry i didnt mention this point in my previous post

I would also like to know the changes done with respect to PPC
architecture in the latest kernel. Any link on that could also be of
some help

Thanks for your time

Cheers,
Balaji

On Tue, Aug 26, 2008 at 9:18 PM, Tobias Koeck <tobias.koeck@gmail.com> wrote:
> Sounds like a litte- and big endian problem.
>
> have you used the ntohl (and similar) conversion methods?
>
> greetings
> tobias
>
> On Tue, Aug 26, 2008 at 5:34 PM, G <balajig81@gmail.com> wrote:
>> Hi
>>
>> I am developing a Linux Kernel Module which basically would do native
>> bridging with VLAN and RSTP. The LKM basically would make use of
>> sk_buff ,net_device, timers, locks etc. I am developing this in i386
>> platform and the kernel version is 2.6.15.4 and it works fine as of
>> now. Now i need to move from i386 to PPC architecture with the same
>> version of the kernel and then move from 2.6.15.4 to 2.6.26 in the PPC
>> architecture.
>>
>> I would like to know whether would i face any big surprises/changes
>> apart from the sk_buff and netdevice data structure changes in the
>> latest versions of the kernel ?
>>
>> Thanks for your help
>>
>> Cheers,
>> Balaji
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
