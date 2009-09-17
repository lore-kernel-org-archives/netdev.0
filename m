From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: remove print_mac as it's not anymore used
Date: Wed, 16 Sep 2009 20:54:17 -0700 (PDT)
Message-ID: <20090916.205417.253183573.davem@davemloft.net>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
	<1253146059-4169-2-git-send-email-plagnioj@jcrosoft.com>
	<20090916.205159.191998627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: plagnioj@jcrosoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760148AbZIQDyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 23:54:00 -0400
In-Reply-To: <20090916.205159.191998627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 16 Sep 2009 20:51:59 -0700 (PDT)

> From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Date: Thu, 17 Sep 2009 02:07:39 +0200
> 
>> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> 
> Applied.

Actually I had to revert.  It's still used by the FCOE stack in
the scsi layer.

Did you actually run grep on the entire tree to see if it's still used
anywhere or did you only check drivers/net/ and net/ or something
equally lazy?
