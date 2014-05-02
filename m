From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: clarify hwmon Kconfig dependency
Date: Fri, 02 May 2014 16:09:51 -0400 (EDT)
Message-ID: <20140502.160951.396568397404555176.davem@davemloft.net>
References: <4879713.xMSSnUPZKf@wuerfel>
	<036FA1BC4A80D448AB7D9C3AAFBBCAF5B68382@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, shahed.shaikh@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com
To: harish.patil@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbaEBUJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 16:09:53 -0400
In-Reply-To: <036FA1BC4A80D448AB7D9C3AAFBBCAF5B68382@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>
Date: Wed, 30 Apr 2014 15:51:27 +0000

> Can we make it into an one line expression as done in few other cases:
 ...
>         bool "QLOGIC QLCNIC 82XX and 83XX family HWMON support"
> -       depends on QLCNIC && HWMON
> +       depends on QLCNIC && HWMON && !(QLCNIC=y && HWMON=m)

Indeed this is much better and is consistent with what other driver
Kconfig entries use.

Can someone formally submit this without the email client patch
corruption and proper signoffs?

Thanks!
