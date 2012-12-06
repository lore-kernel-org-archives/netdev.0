From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: Should we report bus width/speed via ethtool?
Date: Wed, 05 Dec 2012 16:20:34 -0800
Message-ID: <50BFE4D2.90707@inria.fr>
References: <50BFBE05.7020408@candelatech.com> <20121205.173650.1310171220758794440.davem@davemloft.net> <50BFD417.7070306@candelatech.com> <20121205.190121.1400827550469329286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:37784 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444Ab2LFAbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 19:31:08 -0500
In-Reply-To: <20121205.190121.1400827550469329286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/12/2012 16:01, David Miller a =E9crit :
> lspci might be a good place to figure this out :-) It's probably
> grovelling around in PCI config space to determine these things.

Right, it looks from PCI_EXP_LNKSTA in the config space (only works as
root). Here's how we do the same in hwloc (using the pciutils lib
underneath):
  =20
https://svn.open-mpi.org/trac/hwloc/browser/trunk/src/topology-libpci.c=
#L399

Brice
