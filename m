From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Tue, 11 Aug 2009 15:15:48 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908111514090.27712@gentwo.org>
References: <20090807170600.9a2eff2e.billfink@mindspring.com> <4A7C9A14.7070600@inria.fr> <20090807175112.a1f57407.billfink@mindspring.com> <4A7CCEFC.7020308@myri.com> <20090807213557.d0faec23.billfink@mindspring.com> <4A7D5CA4.3030307@myri.com>
 <20090808112636.GB18518@localhost.localdomain> <4A7DC230.6060206@myri.com> <20090808183251.GA23300@localhost.localdomain> <20090811033210.6b422ed1.billfink@mindspring.com> <20090811110254.GA26516@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bill Fink <billfink@mindspring.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:57864 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751144AbZHKTP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 15:15:59 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0763F82C91A
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 15:37:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oR7PrOGaNcdk for <netdev@vger.kernel.org>;
	Tue, 11 Aug 2009 15:37:51 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3C80D82C91B
	for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 15:37:47 -0400 (EDT)
In-Reply-To: <20090811110254.GA26516@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Aug 2009, Neil Horman wrote:

> Well, its possible that there is a kernel bug, but those tables that you're
> reading are parsed IIRC directly from the systems SRAT table in acpi space.  I'm
> not sure of a way to read those directly from user space, but IIRC if you turn
> on apic debugging they will get dumped out.  It sounds as though perhaps your
> SRAT table is incorrectly reporting the location of your devices.  You may also
> want to look at dumping out your smbios via dmidecode to see where that places
> all your 10G nic cards.

Very likely. Talk to the manufacturer of the machine and make sure that
the ACPI information is correct. NUMA is new to many vendors because of
the recent introduction of newer processor architectures that support NUMA
for the first time in small smp machines.

