From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 08:56:52 -0700
Message-ID: <4714DF44.7000404@linux.intel.com>
References: <1192519787.7205.3.camel@pasglop>	<20071016.004410.85411180.davem@davemloft.net>	<1192523336.7205.13.camel@pasglop> <20071016.013146.28785302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, ossthema@de.ibm.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:53249 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933317AbXJPQCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 12:02:30 -0400
In-Reply-To: <20071016.013146.28785302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Tue, 16 Oct 2007 18:28:56 +1000
> 
>> Allright, so that's an out of tree userland thingy... (which may well
>> work on ppc too I suppose). Definitely not installed by default by my
>> distro so IRQs from the network cards on all x86's using ubuntu gutsy at
>> least are spread to all CPUs :-)
> 
> But the thing does treat network interfaces differently from
> other devices.
> 
and it works on various architectures....
The in-kernel x86 thing is going away (it's actually highly 
suboptimal)....

Yes it's done in userland, this is the right place so far.... out of 
tree... well... there's no good place for such userspace tools in the 
kernel tree currently otherwise I'd love to have it there.
If your distro doesn't install this by default, please file a bug 
against the distro; I know we (Intel) worked with Fedora, RHEL, SuSE 
and Ubuntu to get it included.... maybe others don't?
