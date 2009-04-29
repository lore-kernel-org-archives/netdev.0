From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e100: do not go D3 in shutdown unless system
 is powering off
Date: Tue, 28 Apr 2009 22:42:48 -0700 (PDT)
Message-ID: <20090428.224248.26430814.davem@davemloft.net>
References: <20090428214525.1654.27832.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, cascardo@holoscopio.com,
	rjw@sisk.pl
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37529
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751643AbZD2Fmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 01:42:54 -0400
In-Reply-To: <20090428214525.1654.27832.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 14:45:27 -0700

> After experimenting with kexec with the last merges after 2.6.29, I've
> had some problems when probing e100.  It would not read the eeprom.  After
> some bisects, I realized this has been like that since forever (at least
> 2.6.18).  The problem is that shutdown is doing the same thing that
> suspend does and puts the device in D3 state.  I couldn't find a way to
> get the device back to a sane state in the probe function.  So, based on
> some similar patches from Rafael J. Wysocki for e1000, e1000e, and ixgbe,
> I wrote this one for e100.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> Acked-by: "Rafael J. Wysocki" <rjw@sisk.pl>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
