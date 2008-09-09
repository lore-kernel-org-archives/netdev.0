From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Mon, 08 Sep 2008 17:05:16 -0700 (PDT)
Message-ID: <20080908.170516.176909371.davem@davemloft.net>
References: <1220910837.11655.28.camel@californication>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753904AbYIIAFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:05:23 -0400
In-Reply-To: <1220910837.11655.28.camel@californication>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 08 Sep 2008 23:53:57 +0200

> The first patch is a clear regression that got introduced with
> 2.6.27-rc1 when adding Simple Pairing support. I forgot to decrease the
> reference count on an incoming ACL link. This patch actually makes the
> code simpler.

This is OK.

> The second patch fixes the authentication requirements. We do have to
> separate between service discovery and actual profile channels. This is
> a clear requirement of the Bluetooth Security Mode 4 introduced with the
> addition of the Simple Pairing support. Not fixing this will result in
> broken behavior when doing service discovery with Simple Pairing enabled
> devices.

What regression reported by a user is fixed by this?

This does not look like it is appropriate outside of the merge window.

> The third patch rejects insecure incoming connections. This is a clear
> security issues since we can't rely on the initiator doing the right
> thing and establishing an encrypted link. Malicious devices would just
> skip that step and in that case we have to reject connection attempt
> without going into the connection phase at all.

This is OK.
