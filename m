From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] dont insert socket dentries into
 dentry_hashtable.
Date: Tue, 28 Nov 2006 15:35:31 -0800 (PST)
Message-ID: <20061128.153531.34751359.davem@davemloft.net>
References: <20061025.230615.92585270.davem@davemloft.net>
	<200610311948.48970.dada1@cosmosbay.com>
	<200611221900.36216.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@ftp.linux.org.uk, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53483
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758001AbWK1XfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 18:35:24 -0500
To: dada1@cosmosbay.com
In-Reply-To: <200611221900.36216.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew, I'm fine with these three patches, specifically:

[PATCH] dont insert pipe dentries into dentry_hashtable.
[PATCH] [DCACHE] : avoid RCU for never hashed dentries
[PATCH] [NET] dont insert socket dentries into dentry_hashtable.

Could you toss them into -mm if you haven't already?  This
makes better sense then me putting it into net-2.6.20 since
it touches FS stuff.

Thanks!
