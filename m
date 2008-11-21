From: David Miller <davem@davemloft.net>
Subject: Re: Receive Side Support (RSS) - Adding support into the kernel
Date: Fri, 21 Nov 2008 15:26:12 -0800 (PST)
Message-ID: <20081121.152612.60802006.davem@davemloft.net>
References: <d41814900811210948p2fb2059epbd381a8105ab8959@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brampton@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42539
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755808AbYKUX0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:26:13 -0500
In-Reply-To: <d41814900811210948p2fb2059epbd381a8105ab8959@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Andrew Brampton" <brampton@gmail.com>
Date: Fri, 21 Nov 2008 17:48:22 +0000

> Hi,
> Recently I've been interested in receive side support (RSS)[1], the

It's receive side "scaling", not "support".

> There are three RSS settings which can be configured
> 1) Which fields of the packet get hashed.
> 2) The key used by the hashing algorithm
> 3) The indirection table, which is used to map a 7bit hash value to a
> particular core.

We already have an ethtool interface for configuring aspects of this,
with more knobs on the way.
