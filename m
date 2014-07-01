From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 1/2] rtnetlink: allow to register ops
 without ops->setup set
Date: Tue, 01 Jul 2014 14:40:02 -0700 (PDT)
Message-ID: <20140701.144002.1658009662052517255.davem@davemloft.net>
References: <1403769506-9212-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, cwang@twopensource.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbaGAVkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 17:40:04 -0400
In-Reply-To: <1403769506-9212-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 26 Jun 2014 09:58:25 +0200

> So far, it is assumed that ops->setup is filled up. But there might be
> case that ops might make sense even without ->setup. In that case,
> forbid to newlink and dellink.
> 
> This allows to register simple rtnl link ops containing only ->kind.
> That allows consistent way of passing device kind (either device-kind or
> slave-kind) to userspace.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
