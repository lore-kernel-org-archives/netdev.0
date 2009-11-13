From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/3] macvlan: support for guest vm direct rx/tx
Date: Fri, 13 Nov 2009 13:27:28 -0800
Message-ID: <20091113132728.0f1db7c5@s6510>
References: <4AFAD86A.9070506@trash.net>
	<20091113195201.11184.25766.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, arnd@arndb.de,
	bridge@lists.linux-foundation.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50929 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753147AbZKMV1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 16:27:47 -0500
In-Reply-To: <20091113195201.11184.25766.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 14:55:06 -0500
Patrick Mullaney <pmullaney@novell.com> wrote:

> These patches allow other modules to override the receive
> path of a macvlan. This is being done to support guest
> VMs operating directly over a macvlan. Routines to allow
> creation and deletion of macvlans from in-kernel modules
> were also exposed/added.

Which guest VM, how will it use it? The kernel is not in the business
of providing infrastructure for out of tree patches.

Also, macvlan should really being calling netif_receive_skb()
not going through another queue/softirq cycle.
