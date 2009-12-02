From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Wed, 02 Dec 2009 15:10:07 -0800 (PST)
Message-ID: <20091202.151007.202653587.davem@davemloft.net>
References: <4AE92F4D.6070101@gmail.com>
	<20091029.010009.175904855.davem@davemloft.net>
	<alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kolo@albatani.cz, bugzilla-daemon@bugzilla.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53851
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754388AbZLBXKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 18:10:01 -0500
In-Reply-To: <alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 26 Nov 2009 23:54:53 +0200 (EET)

> [PATCH] tcp: clear hints to avoid a stale one (nfs only affected?)
> 
> Eric Dumazet mentioned in a context of another problem:
> 
> "Well, it seems NFS reuses its socket, so maybe we miss some
> cleaning as spotted in this old patch"
> 
> I've not check under which conditions that actually happens but
> if true, we need to make sure we don't accidently leave stale
> hints behind when the write queue had to be purged (whether reusing
> with NFS can actually happen if purging took place is something I'm
> not sure of).
> 
> ...At least it compiles.
> 
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

I think this is a good safety net even if it doesn't specifically
fix a specific problem.

But I'd like to see this patch tested by the person seeing the
problem so we can know whether that is fixed or not.
