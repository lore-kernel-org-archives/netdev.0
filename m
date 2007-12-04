From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 10:59:05 -0700
Message-ID: <m18x4axrx2.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>
	<20071201202354.672aed18@freepuppy.rosehill>
	<47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net>
	<m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>
	<47544896.7070101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Mark Lord <lkml@rtr.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.osdl.org,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57635 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbXLDSAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 13:00:41 -0500
In-Reply-To: <47544896.7070101@candelatech.com> (Ben Greear's message of "Mon,
	03 Dec 2007 10:19:02 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

>> Regardless of infringement it is incompatible with a complete network
>> namespace implementation.  Further it sounds like the module you are
>> describing defines a kernel ABI without being merged and hopes that
>> ABI will still be supportable in the future.  Honestly I think doing so
>> is horrible code maintenance policy.
>>
> I don't mind if the ABI changes, so long as I can still use something similar.

It has occurred to me that I am seeing an implication here that may in fact not
exist.

My impression of dev_get_by_xxxx is that the function is only able to be used
sanely when being part of the definition of a kernel/userspace interface.  With
the further assumption on my part that you need to define a new instance of
dev_get_by_xxxx 

It has just occurred to me that it is possible to reuse the SIOCBRADDIF
and SIOCBRDELIF for that same purpose without defining a new kernel/userspace
interface.

What and how are you using dev_get_by_xxx?

Eric
