From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 18:38:44 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904121837400.27633@fbirervta.pbzchgretzou.qr>
References: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr> <20090410.230016.176733137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090410.230016.176733137.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2009-04-11 08:00, David Miller wrote:
>From: Jan Engelhardt
>Date: Sat, 11 Apr 2009 07:14:50 +0200 (CEST)
>
>> The fact that `iptables -A` is called a hundred times means you are 
>> doing 100 table replacements -- instead of one. And calling
>> synchronize_net at least a 100 times.
>> 
>> "Wanna use iptables-restore?"
>
>I want to derail this line of thinking as fast as possible.
>
>This is not an acceptable response to this problem.  We made something
>fundamentally slower by several orders of magnitude.
>
>Therefore, saying "Don't insert your firewall rules like that." is not
>a valid response for this regression.
>
>We really have to fix it or revert.
>
Well, there is an extra tool in SUSE's iptables, which collects
rules added this way, and then commits them in one go when you
are done. Perhaps that is an "adequeate" way?
