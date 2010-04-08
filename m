From: David Miller <davem@davemloft.net>
Subject: Re: [patch] stmmac: use resource_size()
Date: Wed, 07 Apr 2010 21:50:16 -0700 (PDT)
Message-ID: <20100407.215016.101138529.davem@davemloft.net>
References: <20100407093546.GF5157@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, joe@perches.com, tj@kernel.org,
	cl@linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab0DHEuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:50:13 -0400
In-Reply-To: <20100407093546.GF5157@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 7 Apr 2010 12:35:46 +0300

> Resource size should be calculated as end - start + 1 because we start
> counting at zero.  I changed the code to resource_size() to do the 
> calculation.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
