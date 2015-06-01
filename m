From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] mpls: fix mpls route deletes to not check
 for route scope
Date: Mon, 01 Jun 2015 15:58:38 -0700 (PDT)
Message-ID: <20150601.155838.2219594213274495927.davem@davemloft.net>
References: <1432751825-40804-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com,
	netdev@vger.kernel.org, vivek@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbbFAW6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 18:58:39 -0400
In-Reply-To: <1432751825-40804-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 27 May 2015 11:37:05 -0700

> -	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
> -		goto errout;
> +	if (nlh->nlmsg_type != RTM_DELROUTE &&
> +		rtm->rtm_scope != RT_SCOPE_UNIVERSE)
> +			goto errout;
> +

This is not indented correctly.

When a conditional spans multiple lines, two things must happen:

1) Each line must end with an operator rather than begin with one.

2) Each line starting with the second must start exactly at the
   first column after the openning parenthesis of the conditional.
   You must use the appropriate number of TAB then SPACE characters
   necessary to achieve this.

Thanks.
