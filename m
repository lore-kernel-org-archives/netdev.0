From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] mpls: support for dead routes
Date: Tue, 01 Dec 2015 15:43:24 -0500 (EST)
Message-ID: <20151201.154324.1248915135840079518.davem@davemloft.net>
References: <1448768313-34809-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbbLAUn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:43:26 -0500
In-Reply-To: <1448768313-34809-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sat, 28 Nov 2015 19:38:33 -0800

> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
> routes due to link events. Also adds code to ignore dead
> routes during route selection.

I agree with Robert's feedback that we probably should use
ACCESS_ONCE(), optionally with a local variable.

Please make this change and I'll apply this patch, thanks Roopa!
