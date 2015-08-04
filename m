From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: Use definition for reserved label checks
Date: Mon, 03 Aug 2015 22:35:15 -0700 (PDT)
Message-ID: <20150803.223515.375865467578538382.davem@davemloft.net>
References: <1438620604-18746-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, tgraf@suug.ch,
	roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbbHDFfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:35:17 -0400
In-Reply-To: <1438620604-18746-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 3 Aug 2015 17:50:04 +0100

> In multiple locations there are checks for whether the label in hand
> is a reserved label or not using the arbritray value of 16. Factor
> this out into a #define for better maintainability and for
> documentation.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
> Resend of an earlier version of this patch that was included as part
> of a larger series. Changes since that version:
>   - Move new #define into userspace header file in line with other
>     well-defined label values. Rename to match.

Applied, thanks.
