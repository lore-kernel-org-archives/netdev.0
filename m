From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Wed, 4 Aug 2010 18:32:50 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008041830290.5516@obet.zrqbmnf.qr>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp> <4C584C63.8010607@trash.net> <x6vd7rwrah@gzp> <x6lj8nwqu4@gzp> <alpine.LSU.2.01.1008032001430.1519@obet.zrqbmnf.qr> <x6sk2vo9eq@gzp> <4C599275.2080007@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Gabor Z. Papp" <gzp@papp.hu>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C599275.2080007@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-08-04 18:16, Patrick McHardy wrote:
>Am 03.08.2010 20:09, schrieb Gabor Z. Papp:
>> * Jan Engelhardt <jengelh@medozas.de>:
>> 
>> | (BTW, with --disable-shared you remove the possibility to use any .so
>> | files whatsoever. You can use --enable-static --enable-shared to get
>> | both "all in one binary" and ".so support".)
>> 
>> And how to force linking the binaries against the static libs?
>> 
>> | The following changes since commit 371cea299f0b2eb100b9fc9fb99089640d2d606f:
>> 
>> |   xtables: remove unnecessary cast (2010-08-03 19:56:11 +0200)
>> 
>> | are available in the git repository at:
>> |   git://dev.medozas.de/iptables master
>> 
>> Fixed, compiled fine.
>
>Thanks, I'll release a .1 with this patch tommorrow.

You probably want to add to your personal release script section one 
that testcompiles all configurations before possibly creating a tarball. 
I do so too with Xtables-addons (all kernels from 2.6.17 onwards, 
quite a disk eater).

./configure --enable-static --enable-shared && make
