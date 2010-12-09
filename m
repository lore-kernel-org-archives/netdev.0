From: David Miller <davem@davemloft.net>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Thu, 09 Dec 2010 10:29:14 -0800 (PST)
Message-ID: <20101209.102914.193709247.davem@davemloft.net>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	<1291906948.19763.16.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srk@ti.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752901Ab0LIS2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 13:28:46 -0500
In-Reply-To: <1291906948.19763.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 09 Dec 2010 15:02:28 +0000

> So you really have no choice - you must implement hardware checksum
> offload if you want any of the others.

Right, advertising SG support is entirely pointless if you aren't
also advertising HW checksumming support.
