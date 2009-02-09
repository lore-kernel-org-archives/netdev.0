From: Patrick McHardy <kaber@trash.net>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Mon, 09 Feb 2009 14:39:12 +0100
Message-ID: <49903200.6040408@trash.net>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>	<49902E35.6060506@trash.net> <20090209143405.76ac6387@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbZBINjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:39:15 -0500
In-Reply-To: <20090209143405.76ac6387@mjolnir.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pierre Ossman wrote:
> On Mon, 09 Feb 2009 14:23:01 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Current kernel version (I think starting with 2.6.28) relay the
>> VLAN tag information to userspace through packet sockets. The
>> current libpcap release from tcpdump.org (or the one Dave keeps
>> in a git tree on kernel.org) supports reconstructing the tags.
>>
> 
> Ah. This is a Fedora 10 machine so it's running a 2.6.27 kernel. I'll
> see if I can do a test with an updated kernel.
> 
> Do you know if dhcpd also uses libpcap so that it will stop seeing
> packets it shouldn't?

I believe it depends on compilation options (but usually does on
modern distributions).
