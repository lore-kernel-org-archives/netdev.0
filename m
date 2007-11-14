From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore
 ethernet addresses
Date: Wed, 14 Nov 2007 14:55:59 -0800 (PST)
Message-ID: <20071114.145559.170046831.davem@davemloft.net>
References: <20071114.120359.21994235.davem@davemloft.net>
	<78C9135A3D2ECE4B8162EBDCE82CAD770289BA74@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa.Honnur@neterion.com, netdev@vger.kernel.org,
	jeff@garzik.org, support@neterion.com
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44414
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754110AbXKNWz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 17:55:59 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD770289BA74@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Wed, 14 Nov 2007 15:57:23 -0500

> [Ram] The version numbers are different for the 2 patches. Was the MSI-X
> leak bug fix applied prior to resubmission (we had swapped the version
> numbers on the patches for resubmission).
> 
> [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local entry
> memories when vector allocation fails 
> +#define DRV_VERSION "2.0.26.6"
> 
> [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore ethernet
> addresses 
> +#define DRV_VERSION "2.0.26.7"

I applied only the leak fix to the stable branch, and only
the ethernet address support patch to the 2.6.25 development
tree.

The bug fix will show up later when the 2.6.25 development
tree gets rebased to upstream (which will have the leak
fix by then).

This is how I do things, and that's why changing the DRV_VERSION
to 2.0.26.7 made no sense.

Therefore it makes the most sense to bump driver version numbers
only when things are entirely self contained.


