From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 01/10] qed: Add module with basic common
 support
Date: Sat, 10 Oct 2015 06:24:52 -0700 (PDT)
Message-ID: <20151010.062452.1106942695684145823.davem@davemloft.net>
References: <1444217127-17557-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1444217127-17557-2-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbbJJNJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 09:09:19 -0400
In-Reply-To: <1444217127-17557-2-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 7 Oct 2015 14:25:18 +0300

> +config QED
> +	tristate "QLogic QED 25/40/100Gb core driver"
> +	depends on PCI && X86_64
> +	---help---
> +	  This enables the support for ...

You should be maximizing the number of platforms that can at least
build test this driver, rather than restricting things so much.

If you are making this restriction because there are x86_64'isms
in this driver, that's even worse.

So I want to see this depending upon "PCI" only.
