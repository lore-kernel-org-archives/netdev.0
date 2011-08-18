From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix IBM EMAC driver after rename.
Date: Wed, 17 Aug 2011 23:49:47 -0700 (PDT)
Message-ID: <20110817.234947.611559275017926008.davem@davemloft.net>
References: <20110818061354.GD19739@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: tony@bakeyournoodle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024Ab1HRGv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 02:51:57 -0400
In-Reply-To: <20110818061354.GD19739@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Breeds <tony@bakeyournoodle.com>
Date: Thu, 18 Aug 2011 16:13:55 +1000

> In commit 9aa3283595451ca093500ff0977b106e1f465586 (ehea/ibm*: Move the
> IBM drivers) the IBM_NEW_EMAC* were renames to IBM_EMAC*
> 
> The conversion was incomplete so that even if the driver was added to
> the .config it wasn't built, but there were no errors)
> 
> This should fix those omissions.
> 
> Tested on a canyondlands board.

You also need to select the dependencies, such as "ETHERNET" for this
to be correct.
