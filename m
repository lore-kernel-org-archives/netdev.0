From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Thu, 24 Apr 2014 11:55:23 -0400 (EDT)
Message-ID: <20140424.115523.296790709263872877.davem@davemloft.net>
References: <CAMEtUuzT6smejsgoKP5c_NCw8mQw39xfPR+hsfV1Oh77ZeG3bA@mail.gmail.com>
	<CAMEtUuy82KA90_0CtkwwZMAXaWbpwtR1RBt9neb1CuX6v-EstA@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6FDD8D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, dborkman@redhat.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758079AbaDXPz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:55:28 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6FDD8D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 24 Apr 2014 08:28:56 +0000

> From: Alexei Starovoitov
> ...
>> Have to correct myself here.
>> sparc is an architecture where args are passed in %o regs
>> and received by the callee in %i regs, so there is a precedent.
> ...
> 
> Not actually true, the parameters are still in the %o regs
> in the called function.
> It is the called function that rotates the register window,
> not the act of making the function call.
> Small leaf functions will typically use the existing register
> window.

Correct.
