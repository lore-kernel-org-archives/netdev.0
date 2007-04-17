From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix UDP checksum issue in net poll mode.
Date: Tue, 17 Apr 2007 12:41:10 -0700 (PDT)
Message-ID: <20070417.124110.99829630.davem@davemloft.net>
References: <6d6a94c50704162353p2b96b3e4kd05489a59aa9bba7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: aubreylee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031164AbXDQTlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:41:08 -0400
In-Reply-To: <6d6a94c50704162353p2b96b3e4kd05489a59aa9bba7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Aubrey Li" <aubreylee@gmail.com>
Date: Tue, 17 Apr 2007 14:53:48 +0800

> In net poll mode, the current checksum function doesn't consider the
> kind of packet which is padded to reach a specific minimum length. I
> believe that's the problem causing my test case failed. The following
> patch fixed this issue.
> 
> Signed-off-by: Aubrey.Li <aubreylee@gmail.com>

This looks good, patch applied, thanks Aubrey.
