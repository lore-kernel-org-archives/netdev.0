From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 13:43:50 -0800 (PST)
Message-ID: <20081112.134350.95617647.davem@davemloft.net>
References: <20081112.035240.226243372.davem@davemloft.net>
	<20081112.041143.11487260.davem@davemloft.net>
	<491B18E0.7040502@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53799
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752822AbYKLVnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 16:43:50 -0500
In-Reply-To: <491B18E0.7040502@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Wed, 12 Nov 2008 18:56:48 +0100

> I sort-of reliably hit the problem after a few day of production on
> a 16 core, amd64 system running NFS-server.
>
> Does it seem likely to be the same problem?

Not really, it sounds like you're using a 64-bit kernel (this only
effects 32-bit ones) and the problem triggers after the first 256
packets are sent to the send destination so it should happen quickly.
