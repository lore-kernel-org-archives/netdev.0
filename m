From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netns 1/2: don't get/put old netns on CLONE_NEWNET
Date: Mon, 04 May 2009 11:11:47 -0700 (PDT)
Message-ID: <20090504.111147.124526771.davem@davemloft.net>
References: <20090503232825.GF16631@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755781AbZEDSLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 14:11:52 -0400
In-Reply-To: <20090503232825.GF16631@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 4 May 2009 03:28:25 +0400

> copy_net_ns() doesn't copy anything, it creates fresh netns, so get/put of old
> netns isn't needed.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Acked-by: Serge Hallyn <serue@us.ibm.com>

Applied to net-next-2.6
