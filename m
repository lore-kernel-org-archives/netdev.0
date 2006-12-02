From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED] act_gact: division by zero
Date: Fri, 01 Dec 2006 20:21:56 -0800 (PST)
Message-ID: <20061201.202156.89126262.davem@davemloft.net>
References: <456ECBC5.3080501@trash.net>
	<Pine.LNX.4.44.0611301530590.4036-100000@dhcp09282.ntc.nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:2982
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031607AbWLBEVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 23:21:49 -0500
To: Kim.Nordlund@nokia.com
In-Reply-To: <Pine.LNX.4.44.0611301530590.4036-100000@dhcp09282.ntc.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
Date: Thu, 30 Nov 2006 15:51:04 +0200 (EET)

> 
> On Thu, 30 Nov 2006, ext Patrick McHardy wrote:
> > I think it should reject an invalid configuration or handle
> > the zero case correctly by not dividing.
> 
> You are correct. Not returning -EINVAL, because someone might
> want to use the value zero in some future gact_prob algorithm?
> 
> Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>

Applied, thanks Kim.
