From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: Do the correct cleanup after an unprivileged
 SIOCSIFADDR.
Date: Wed, 08 Dec 2010 10:14:05 -0800 (PST)
Message-ID: <20101208.101405.104050937.davem@davemloft.net>
References: <1291589152-4640-1-git-send-email-nelhage@ksplice.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philb@gnu.org, netdev@vger.kernel.org, stable@kernel.org
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754870Ab0LHSNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:13:38 -0500
In-Reply-To: <1291589152-4640-1-git-send-email-nelhage@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Elhage <nelhage@ksplice.com>
Date: Sun,  5 Dec 2010 17:45:52 -0500

> We need to drop the mutex and do a dev_put, so set an error code and break like
> the other paths, instead of returning directly.
> 
> Cc: stable@kernel.org
> Signed-off-by: Nelson Elhage <nelhage@ksplice.com>

Applied, thanks Nelson.
