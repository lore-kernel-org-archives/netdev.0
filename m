From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 14/20] staging/appletalk: remove the BKL
Date: Wed, 26 Jan 2011 13:57:37 +0100
Message-ID: <201101261357.38132.arnd@arndb.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de> <1295993854-4971-15-git-send-email-arnd@arndb.de> <20110125.142926.246535705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:65533 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997Ab1AZM5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 07:57:44 -0500
In-Reply-To: <20110125.142926.246535705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 January 2011, David Miller wrote:
> If you're moving appletalk to staging because "nobody is motivated
> enough to remove the BKL" and then you actually do the work to remove
> the BKL, I really don't see any point in doing the whole staging
> thing.
> 
> We always keep an eye on every protocol that sits under the top-level
> net/.  Every socket API change propagates, as does every other
> networking API change that matters for those protocols.

Ok, fair enough. I've removed the "move to staging" patch now from my
series. I'm going to need some help with testing, or at least thoroughly
reviewing the patch, since I am not extremely confident in my own work
there.

	Arnd
