From: David Miller <davem@davemloft.net>
Subject: Re: [netfilter-core] [2.6 patch] remove ip{,6}_queue
Date: Fri, 01 Dec 2006 20:10:28 -0800 (PST)
Message-ID: <20061201.201028.71163999.davem@davemloft.net>
References: <20061201205954.GH11084@stusta.de>
	<4570B912.6060105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, laforge@netfilter.org, netdev@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:64729
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1162764AbWLBEKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 23:10:22 -0500
To: kaber@trash.net
In-Reply-To: <4570B912.6060105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 02 Dec 2006 00:21:54 +0100

> We really can't remove ip_queue. Many users use this, there is no binary
> compatible interface and even the compat replacement for the originally
> statically linked library doesn't work. There is also no real necessity
> to remove the code, so the feature-removal-schedule entry should be
> removed instead.
> 
> Dave, please apply this patch. Thanks.

Done, thanks.
