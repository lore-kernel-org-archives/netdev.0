From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/8] qlcnic: Bug fixes
Date: Sat, 11 May 2013 16:01:47 -0700 (PDT)
Message-ID: <20130511.160147.301435350728128819.davem@davemloft.net>
References: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3EKXBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 19:01:49 -0400
In-Reply-To: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Thu, 9 May 2013 15:25:08 -0400

> This patch series has following bug fixes:
> * Fix a bug in unicast MAC address setting in adapter.
>   Driver was not deleting older unicast MAC while adding new one.
> * Fix an ethtool stats string array by adding missing string entry
>   and fix a typo.
> * Fix module paramter description. Bracket ')' was missing.
> * Fix port status provided though 'ethtool <device>' for 83xx adapter.
> * Fix reset recovery path in case of transmit timeout.
> * Fix reset recovery during diagnostic tests by preserving
>   current device status information.
> * Fix mailbox response handling. Driver was not maintaining poll time properly.
> * Fix validation of link event command.

Series applied, thanks.
