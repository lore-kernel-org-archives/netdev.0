From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Tue, 07 Apr 2009 16:08:26 -0400
Message-ID: <49DBB2BA.1010100@athenacr.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BED109.3020504@cosmosbay.com> <49D66379.7070106@athenacr.com> <49D8B6DA.7050902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1040 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753692AbZDGUIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 16:08:30 -0400
In-Reply-To: <49D8B6DA.7050902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
 > Brian Bloniarz a =E9crit :
 >> We've been experimenting with this softirq-delay patch in productio=
n, and
 >> have seen some hard-to-reproduce crashes. We finally managed to cap=
ture a
 >> kexec crashdump this morning.
 >
 > Pointer being null might tell us that we managed to call inet_def_re=
adable()
 > without socket lock hold...

=46alse alarm -- I think I did the backport to 2.6.24 incorrectly. 2.6.=
24 was
before the UDP receive path started taking the socket lock, so
inet_def_readable's assumption doesn't hold.

Sorry to waste everyone's time.

Thanks,
Brian Bloniarz
