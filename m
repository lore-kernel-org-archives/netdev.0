From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh_eth: check platform data pointer
Date: Mon, 04 Nov 2013 15:49:49 -0500 (EST)
Message-ID: <20131104.154949.7139336717561192.davem@davemloft.net>
References: <201310302330.19491.sergei.shtylyov@cogentembedded.com>
	<20131031060527.GV1603@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: horms@verge.net.au
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20131031060527.GV1603@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Thu, 31 Oct 2013 15:05:27 +0900

> [ Cc Dave Miller ]
> 
> On Wed, Oct 30, 2013 at 11:30:19PM +0300, Sergei Shtylyov wrote:
>> Check the platform data pointer before dereferencing it and error out of the
>> probe() method if it's NULL.
>> 
>> This has additional effect of preventing kernel oops with outdated platform data
>> containing zero PHY address instead (such as on SolutionEngine7710).
>> 
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Acked-by: Simon Horman <horms+renesas@verge.net.au>
> 
> Dave, is it too late to for this to be considered for net-next?

Applied, thanks.
