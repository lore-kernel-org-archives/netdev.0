From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Tue, 24 Jul 2012 00:26:51 +0300
Message-ID: <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
	<500BD558.2060803@mellanox.com>
	<20120722.171553.2139258607165498367.davem@davemloft.net>
	<500D4F31.9020408@linux.vnet.ibm.com>
	<500D556F.4000409@mellanox.com>
	<500D93F5.4090305@linux.vnet.ibm.com>
	<500DB9CE.5080100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	cascardo@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	shlomop@mellanox.com
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:58086 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007Ab2GWV0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:26:52 -0400
Received: by ghrr11 with SMTP id r11so5997173ghr.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 14:26:52 -0700 (PDT)
In-Reply-To: <500DB9CE.5080100@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com> wrote:
>> For powerpc we have an IBM internal user space tool that injects the
>> error on the bus with the aid of the system firmware. The kernel used
>> was built with the option:
>> CONFIG_EEH=y
>> and without the AER options. I will run some more tests with the AER
>> options activated.

> I tested the powerpc error injection with
>
> CONFIG_EEH=y
> CONFIG_PCIEAER=y
> CONFIG_PCIEAER_INJECT=m
>
> and with the aer_inject module loaded and it didn't affect the EEH
> recovery, the adapter recovered as expected.

I wasn't sure to follow what did you mean by "it didn't affect the EEH
recovery", how did you use the aer_inject module, is that through
user-space tool which is available for us?

Or.
