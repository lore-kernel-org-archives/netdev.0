From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Tue, 24 Jul 2012 20:09:56 +0300
Message-ID: <500ED6E4.60909@mellanox.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <500BD558.2060803@mellanox.com> <20120722.171553.2139258607165498367.davem@davemloft.net> <500D4F31.9020408@linux.vnet.ibm.com>	<500D556F.4000409@mellanox.com> <500D93F5.4090305@linux.vnet.ibm.com>	<500DB9CE.5080100@linux.vnet.ibm.com> <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com> <500E9F2E.4010209@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jackm@dev.mellanox.co.il>, <yevgenyp@mellanox.co.il>,
	<cascardo@linux.vnet.ibm.com>, <brking@linux.vnet.ibm.com>
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:56468 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755758Ab2GXRLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 13:11:17 -0400
In-Reply-To: <500E9F2E.4010209@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/2012 4:12 PM, Kleber Sacilotto de Souza wrote:
> On 07/23/2012 06:26 PM, Or Gerlitz wrote:
>
>> Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com> wrote:
>>>> For powerpc we have an IBM internal user space tool that injects the
>>>> error on the bus with the aid of the system firmware. The kernel used
>>>> was built with the option:
>>>> CONFIG_EEH=y
>>>> and without the AER options. I will run some more tests with the AER
>>>> options activated.
>>> I tested the powerpc error injection with
>>>
>>> CONFIG_EEH=y
>>> CONFIG_PCIEAER=y
>>> CONFIG_PCIEAER_INJECT=m
>>>
>>> and with the aer_inject module loaded and it didn't affect the EEH
>>> recovery, the adapter recovered as expected.
>> I wasn't sure to follow what did you mean by "it didn't affect the EEH
>> recovery", how did you use the aer_inject module, is that through
>> user-space tool which is available for us?
>
> I wanted to say that I was testing before only with the EEH option
> activated, then I activated the AER options on my powerpc system just to
> make sure these options when activate wouldn't affect the EEH recovery.
> I haven't injected and AER error since I don't have a system with
> hardware support for it.
>
>
> Thanks,

Hi

Using a special extender card I've powered down the card.
None of the callbacks were called (I added printks to be sure).
Shouldn't one on the callbacks be called?

Shlomo Pongratz.
