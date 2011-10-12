From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Wed, 12 Oct 2011 16:24:50 +0200
Message-ID: <4E95A332.1040806@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <20111012132822.GJ2840382@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lennert Buytenhek <kernel@wantstofly.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:20225 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751076Ab1JLOY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 10:24:57 -0400
In-Reply-To: <20111012132822.GJ2840382@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Lamparter wrote:
> On Wed, Oct 12, 2011 at 01:51:22AM +0200, Arvid Brodin wrote:
>> Stephen Hemminger wrote:
>>>> I want to add support for HSR ("High-availability Seamless Redundancy",
>>>> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
>>>> ports and are connected in a ring. All new Ethernet packets are sent on both
>>>> ports (or passed through if the current unit is not the originating unit).
> 
> 
>>>> The same packet is never passed twice.
> 
> How does the bridge decide whether a packet is arriving the second time?
> Is the ring pre-resolved to stop things or does this happen per-packet?

It happens per-packet. I believe a combination of source MAC address and the HSR
sequence tag is used to identify duplicates.

-- 
Arvid Brodin
Enea Services Stockholm AB
