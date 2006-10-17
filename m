From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/14] [TIPC] Fixed slow link reactivation when link
 tolerance is large
Date: Mon, 16 Oct 2006 21:57:24 -0700 (PDT)
Message-ID: <20061016.215724.102122744.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<116073947515-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51147
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423063AbWJQE5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:57:25 -0400
To: per.liden@ericsson.com
In-Reply-To: <116073947515-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:51 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch corrects an issue wherein a previouly failed node could
> not reestablish a links to a non-failing node in the TIPC network
> until the latter node detected the link failure itself (which might
> be configured to take up to 30 seconds).  The non-failing node now
> responds to link setup requests from a previously failed node in at
> most 1 second, allowing it to detect the link failure more quickly.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks.
