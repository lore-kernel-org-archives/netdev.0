From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 20 Aug 2009 03:26:01 -0400
Message-ID: <20090820032601.03a628cf.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
	<20090811033210.6b422ed1.billfink@mindspring.com>
	<87ws5af0km.fsf@basil.nowhere.org>
	<20090812003049.185cd52a.billfink@mindspring.com>
	<4A856781.2080301@myri.com>
	<20090814123832.a7a27a9d.billfink@mindspring.com>
	<4A859716.7040904@myri.com>
	<3000d2e90908141413h3e3eae1dm796f4bf788319561@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Gallatin <gallatin@myri.com>, netdev@vger.kernel.org
To: Aviv Greenberg <avivgnet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:59725
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753931AbZHTH0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 03:26:02 -0400
In-Reply-To: <3000d2e90908141413h3e3eae1dm796f4bf788319561@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Aug 2009, Aviv Greenberg wrote:

> >  There may be something in the chipset
> 
> shooting in the dark: when you lspci -vvv and check the MaxPayload and
> MaxReadReq values for the myri devices - what are the values and are
> they equal? Are they the same on all your platforms?

IIRC, under DevCap they indicated MaxPayload 4096 bytes, and under
DevCtl they indicated MaxPayload 128 bytes and MaxReadReq 4096 bytes,
and was the same on both the Asus and SuperMicro systems.  I will
doublecheck tomorrow at work.  I am not clear on the meanings of
the different parameters.  And is DevCtl for PCI control messages
and DevCap for actual data transfers or something else?

						-Thanks

						-Bill
