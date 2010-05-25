From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: Bug fix to avoid disabling bottom half
 during firmware upgrade.
Date: Tue, 25 May 2010 16:16:40 -0700 (PDT)
Message-ID: <20100525.161640.189696312.davem@davemloft.net>
References: <20100525081514.GA5695@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932635Ab0EYXQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 19:16:30 -0400
In-Reply-To: <20100525081514.GA5695@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Tue, 25 May 2010 13:45:24 +0530

> Certain firmware commands/operations to upgrade firmware could take several
> seconds to complete. The code presently disables bottom half during these
> operations which could lead to unpredictable behaviour in certain cases. This
> patch now does all firmware upgrade operations asynchronously using a
> completion variable.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied, thanks.
