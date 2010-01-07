From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Staging: Octeon Ethernet: Clean up and convert to
 NAPI.
Date: Wed, 06 Jan 2010 17:01:38 -0800 (PST)
Message-ID: <20100106.170138.71108684.davem@davemloft.net>
References: <4B4530F3.1070701@caviumnetworks.com>
	<1262825836-9457-2-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38565
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752243Ab0AGBBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 20:01:34 -0500
In-Reply-To: <1262825836-9457-2-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed,  6 Jan 2010 16:57:15 -0800

> Convert the driver to be a reasonably well behaved NAPI citizen.  Also
> clean up memory allocation and tx buffer accounding code.  Remove some
> configuration #defines and other unused code that are not applicable
> to the in-tree driver.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Please seperate the cleanups and conversion to NAPI into seperate
patches.

Doing both at the same time makes your patch impossible to review.
