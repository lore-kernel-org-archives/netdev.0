From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: Re: [PATCH v3 3/3] stmmac: pci: add MSI support for Intel Quark X1000
Date: Mon, 02 Feb 2015 15:50:23 +0000
Message-ID: <54CF9CBF.7080806@nexus-software.ie>
References: <54CF94FF.1050802@nexus-software.ie> <1422891987.31903.374.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	davem@davemloft.net, "Ahmad, Josef" <josef.ahmad@intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-smtp03.blacknight.com ([81.17.249.16]:55946 "EHLO
	outbound-smtp03.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753976AbbBBPu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 10:50:27 -0500
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8BC192F80D2
	for <netdev@vger.kernel.org>; Mon,  2 Feb 2015 15:50:25 +0000 (UTC)
In-Reply-To: <1422891987.31903.374.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/15 15:46, Andy Shevchenko wrote:
> On Mon, 2015-02-02 at 15:17 +0000, Bryan O'Donoghue wrote:
>> Hi guys.
>>
>> Has the issue with PVM masking been addressed ?
>>
>> https://lkml.org/lkml/2014/10/1/221
>>
>> If not then please drop MSIs from this patchset.
>
> I do not see the reason why it should be done on per driver basis.

Agree.

> Care to fix this under arch/x86 then when adding new Quark platform?

Looking into that now.

Hmm - OK -let's aim to get a fix in for the bridge and leave the MSI 
enable in place.
