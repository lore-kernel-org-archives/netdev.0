From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] mlx4: mlx4_core failed to load
Date: Mon, 28 Apr 2014 15:59:00 -0400 (EDT)
Message-ID: <20140428.155900.1619506417111671946.davem@davemloft.net>
References: <20140428183330.201681971@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbaD1T7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:59:02 -0400
In-Reply-To: <20140428183330.201681971@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Mon, 28 Apr 2014 13:33:30 -0500

> This is for a case where mlx4_core fails to load.

You cannot just will-nilly delete module parameters that you decide
you don't want to support any more.

Once you add a module parameter, you are stuck with it forever once
it makes it into a released kernel.  It is a user visible interface.

I'm not applying this patch, you have to actually fix the bug rather
then wholesale remove the facility altogether.
