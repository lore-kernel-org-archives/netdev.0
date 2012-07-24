From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Tue, 24 Jul 2012 10:12:14 -0300
Message-ID: <500E9F2E.4010209@linux.vnet.ibm.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <500BD558.2060803@mellanox.com> <20120722.171553.2139258607165498367.davem@davemloft.net> <500D4F31.9020408@linux.vnet.ibm.com>	<500D556F.4000409@mellanox.com> <500D93F5.4090305@linux.vnet.ibm.com>	<500DB9CE.5080100@linux.vnet.ibm.com> <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	cascardo@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	shlomop@mellanox.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:41589 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab2GXNMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 09:12:24 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <klebers@linux.vnet.ibm.com>;
	Tue, 24 Jul 2012 10:12:19 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 04E961DC004D
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 09:12:16 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6ODBTWC23199946
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 10:11:29 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6OBC9lE032361
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 08:12:10 -0300
In-Reply-To: <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2012 06:26 PM, Or Gerlitz wrote:

> Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com> wrote:
>>> For powerpc we have an IBM internal user space tool that injects the
>>> error on the bus with the aid of the system firmware. The kernel used
>>> was built with the option:
>>> CONFIG_EEH=y
>>> and without the AER options. I will run some more tests with the AER
>>> options activated.
> 
>> I tested the powerpc error injection with
>>
>> CONFIG_EEH=y
>> CONFIG_PCIEAER=y
>> CONFIG_PCIEAER_INJECT=m
>>
>> and with the aer_inject module loaded and it didn't affect the EEH
>> recovery, the adapter recovered as expected.
> 
> I wasn't sure to follow what did you mean by "it didn't affect the EEH
> recovery", how did you use the aer_inject module, is that through
> user-space tool which is available for us?


I wanted to say that I was testing before only with the EEH option
activated, then I activated the AER options on my powerpc system just to
make sure these options when activate wouldn't affect the EEH recovery.
I haven't injected and AER error since I don't have a system with
hardware support for it.


Thanks,
-- 
Kleber Sacilotto de Souza
IBM Linux Technology Center
