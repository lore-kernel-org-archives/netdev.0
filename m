From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH, RFC] bonding: prevent outgoing packets on inactive
	slaves
Date: Thu, 6 Aug 2009 12:43:56 +0200
Message-ID: <20090806104356.GA8024@midget.suse.cz>
References: <20090805162429.GD16093@midget.suse.cz> <4A79BA01.502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Bohac <jbohac@suse.cz>, fubar@us.ibm.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44447 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbZHFKn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 06:43:59 -0400
Content-Disposition: inline
In-Reply-To: <4A79BA01.502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2009 at 06:57:37PM +0200, Eric Dumazet wrote:
> Jiri Bohac a =E9crit :
> > This patch makes sure the TX queues on inactive slaves are
> > deactivated.
> >=20
>=20
> Wont this break ARP link monitoring ?

No, ARP monitoring sends the ARP requests from the active slave.

--=20
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

