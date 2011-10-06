From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Asserting ECN from userspace?
Date: Thu, 06 Oct 2011 16:52:05 -0700
Message-ID: <m2hb3l3cgq.fsf@firstfloor.org>
References: <4E8BF6B2.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
To: David =?utf-8?Q?T=C3=A4ht?= <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34889 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935786Ab1JFXwH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 19:52:07 -0400
In-Reply-To: <4E8BF6B2.6030101@gmail.com> ("David =?utf-8?Q?T=C3=A4ht=22's?=
 message of "Tue, 04
	Oct 2011 23:18:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David T=C3=A4ht <dave.taht@gmail.com> writes:
>
> And twiddling them, on a per stream basis, for a single packet, would
> seem to require something more robust than setsockopt/getsockopt
> (although that would work for udp streams)

With netfilter nf_queue you can construct a rule that passes packets
through user space and reinjects them.

I would suggest to just use that to modify the ECN bits.

I'm sure with reasonable google skills you can find some examples
how to do this on the web.

-Andi


--=20
ak@linux.intel.com -- Speaking for myself only
