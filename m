From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: Allow mpls_gso and mpls_router to be
 built as modules
Date: Wed, 11 Mar 2015 16:39:11 -0400 (EDT)
Message-ID: <20150311.163911.2302289395111906495.davem@davemloft.net>
References: <1426005479-21806-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbCKUjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:39:13 -0400
In-Reply-To: <1426005479-21806-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Tue, 10 Mar 2015 16:37:59 +0000

> CONFIG_MPLS=m doesn't result in a kernel module being built because it
> applies to the net/mpls directory, rather than to .o files.
> 
> So revert the MPLS menuitem to being a boolean and make MPLS_GSO and
> MPLS_ROUTING tristates to allow mpls_gso and mpls_router modules to be
> produced as desired.
> 
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied.
