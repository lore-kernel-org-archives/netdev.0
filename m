From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Wed, 09 Jan 2008 00:39:52 -0800 (PST)
Message-ID: <20080109.003952.25384040.davem@davemloft.net>
References: <20080108213640.GC4450@electric-eye.fr.zoreil.com>
	<20080109003840.22917.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751894AbYAIIjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:39:53 -0500
In-Reply-To: <20080109003840.22917.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: linux@horizon.com
Date: 8 Jan 2008 19:38:40 -0500

> That doesn't seem to do it.  Not entirely, at least.  After downloading
> and partially re-uploading an 800M file, slabtop reports:

Ok, I'll let you and Francois work out how to fix this for
good.

Please submit just the outright leak bug fixes once this is
all resolved.  All of that code cleanup stuff needs to wait
until later, let's fix bugs before adding new ones. :-)

Thanks.
