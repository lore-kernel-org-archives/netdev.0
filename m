From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Wed, 27 Feb 2008 23:51:10 -0800 (PST)
Message-ID: <20080227.235110.242439399.davem@davemloft.net>
References: <20080228014125.GI3078@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47369
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751633AbYB1HvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 02:51:12 -0500
In-Reply-To: <20080228014125.GI3078@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 27 Feb 2008 20:41:25 -0500

> Gordon Farquharson (1):
>       Fix b43 driver build for arm

Please revert this change and resend your pull request.

If file2alias doesn't work properly in a cross build environment, we
don't fix it by crapping up mod_devalias.h with these silly align
attribute annotations.

Thanks.
