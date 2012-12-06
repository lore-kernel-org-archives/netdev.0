From: Ben Greear <greearb@candelatech.com>
Subject: Re: Should we report bus width/speed via ethtool?
Date: Wed, 05 Dec 2012 16:44:39 -0800
Message-ID: <50BFEA77.5060305@candelatech.com>
References: <50BFBE05.7020408@candelatech.com> <20121205.173650.1310171220758794440.davem@davemloft.net> <50BFD417.7070306@candelatech.com> <20121205.190121.1400827550469329286.davem@davemloft.net> <50BFE4D2.90707@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60809 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967Ab2LFAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 19:44:52 -0500
In-Reply-To: <50BFE4D2.90707@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2012 04:20 PM, Brice Goglin wrote:
> Le 05/12/2012 16:01, David Miller a =E9crit :
>> lspci might be a good place to figure this out :-) It's probably
>> grovelling around in PCI config space to determine these things.
>
> Right, it looks from PCI_EXP_LNKSTA in the config space (only works a=
s
> root). Here's how we do the same in hwloc (using the pciutils lib
> underneath):
>
> https://svn.open-mpi.org/trac/hwloc/browser/trunk/src/topology-libpci=
=2Ec#L399

Thanks..but it seems easier to just parse the text output of lspci -vvv

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
