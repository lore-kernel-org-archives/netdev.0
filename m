From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/14] [TIPC] Stream socket can now send > 66000 bytes
 at a time
Date: Mon, 16 Oct 2006 21:44:05 -0700 (PDT)
Message-ID: <20061016.214405.38322267.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394753960-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37026
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423041AbWJQEoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:44:04 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394753960-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:44 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> The stream socket send code was not initializing some required fields
> of the temporary msghdr structure it was utilizing; this is now fixed.
> A check has also been added to detect if a user illegally specifies
> a destination address when sending on an established stream connection.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks.
