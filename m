From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released
Date: Wed, 31 Aug 2016 22:31:37 +0200
Message-ID: <10509740.e7IeEJdM2T@wuerfel>
References: <20160831123911.3467676-2-arnd@arndb.de> <20160831123911.3467676-1-arnd@arndb.de> <32608.1472675146@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:55066 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752600AbcHaUbj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 16:31:39 -0400
In-Reply-To: <32608.1472675146@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, August 31, 2016 9:25:46 PM CEST David Howells wrote:
> Is there a 1/2 somewhere?  I don't see it.
> 
> David

Sorry, mixed up the Cc list. It only went to netdev and lkml and isn't
really related. That one was a workaround for a false-positive
 -Wmaybe-uninitialized warning in NFS, see https://lkml.org/lkml/2016/8/31/412

	Arnd
