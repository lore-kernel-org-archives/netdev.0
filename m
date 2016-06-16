From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Add Light L2 [ll2] infrastructure
Date: Wed, 15 Jun 2016 22:17:01 -0700 (PDT)
Message-ID: <20160615.221701.587394586942508875.davem@davemloft.net>
References: <1465986157-16186-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbcFPFRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:17:02 -0400
In-Reply-To: <1465986157-16186-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 15 Jun 2016 13:22:37 +0300

> The qed driver will allow support for several drivers other than
> qede, and each of said protocol drivers will require some sort of
> L2-like ability to send and receive traffic -
> the common use-case would be for control traffic specific for the
> protocol that needs to reach user/kernel tools, although other cases
> exist as well [some of which are for internal use by firmware].

You have to describe in more detail who these users will be.

Actually, you are required to submit a use case along with any new
facility and set of interfaces like this.

Otherwise it is impossible to review the facility and make sure it
does what it is supposed to do, and is designed well for it's intended
use case.
