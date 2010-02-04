From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 04 Feb 2010 17:49:37 +0100
Message-ID: <4B6AFAA1.5080703@trash.net>
References: <4B6AC467.7020209@redhat.com> <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr> <4B6ADA3A.7040201@trash.net> <alpine.LSU.2.01.1002041542150.13435@obet.zrqbmnf.qr> <4B6ADFFB.4050407@trash.net> <alpine.LSU.2.01.1002041743360.21982@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Woerner <twoerner@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1002041743360.21982@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
>> The kernel also forbids ".".
> 
> My first thought was the same, but:
> 
> a) Interestingly, it does not prohibit '.'
> 
> 	ip tunnel add foo0.3 mode sit local 1.2.3.4 remote 5.6.7.8
> 
> b) The '.' is to be seen as valid as far as xtables.c goes, so
>    as to match VLAN interfaces.

Ah of course, its only invalid at the beginning of the name.
