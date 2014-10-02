From: Eli Cohen <eli@mellanox.com>
Subject: RE: [PATCH V1 net-next 2/4] net/mlx5_core: Use hardware registers
 description header file
Date: Thu, 2 Oct 2014 09:21:35 +0000
Message-ID: <CFE9BFE80FFE4D4892AA5D31387E310F014FC6E18F@MTLDAG02.mtl.com>
References: <1412169488-17500-1-git-send-email-eli@mellanox.com>
	<1412169488-17500-3-git-send-email-eli@mellanox.com>
	<CAADnVQ+0q=j9soWX-ge6Re4F6sDahq=O-Ptaguca8WUaTE-qQw@mail.gmail.com>
 <20141001.145615.234381013367053243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"joe@perches.com" <joe@perches.com>
To: David Miller <davem@davemloft.net>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:46655 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750919AbaJBJVo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 05:21:44 -0400
In-Reply-To: <20141001.145615.234381013367053243.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Indeed, please don't invent your own facilities for compile-time checks,
> we have BUILD_BUG_ON() so please use it instead of non_existent_function()
> which BTW doesn't work with some non-gcc compilers.

Sent V2 series with all comments addressed.
