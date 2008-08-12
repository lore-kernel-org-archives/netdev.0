From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 22:06:37 -0400
Message-ID: <48A0F02D.7030800@hp.com>
References: <48A0DC27.7030208@hp.com>	<28fa9c5e0808111810l63220abbgf9e747bad3a7fe44@mail.gmail.com>	<28fa9c5e0808111828w2a9f1133y75c785f70b683ff2@mail.gmail.com> <20080811.184026.02436525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eugeneteo@kernel.sg, parag.warudkar@gmail.com,
	akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:40723 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbYHLCGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 22:06:41 -0400
In-Reply-To: <20080811.184026.02436525.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Hmmm... from what I understand so far based upon Parag's most
> recent reply, Brian's patch should be OK.
> 
> Does everyone else agree?

Just an fyi I think part of the confusion was the output I posted:

# ip -f inet6 route get fec0::1
unreachable fec0::1 dev lo  table unspec  proto none  src
2001:1890:1109:a10:218:feff:fe7f:49c8  metric -1  error -101 hoplimit 255

On my system I have a global address on eth0, so that's printed in my 
output.  Others don't have a global, so see ::1, which is expected.  I 
see the same behavior on my Debian Lenny 2.6.18 box as 2.6.27, so my 
patch doesn't seem to have changed anything.

-Brian
