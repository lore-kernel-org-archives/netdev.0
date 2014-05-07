From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] ipv4: move local_port_range out of
 CONFIG_SYSCTL
Date: Thu, 8 May 2014 00:48:48 +0200
Message-ID: <20140507224848.GA1272@electric-eye.fr.zoreil.com>
References: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
 <20140507.172641.1968628089443229607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56286 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaEGWsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 18:48:55 -0400
Content-Disposition: inline
In-Reply-To: <20140507.172641.1968628089443229607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> I think these two changes fix fairly serious issues that have existed for some
> time, so it should go into 'net', do you agree?

Patch #1, yes.

Without patch #2, the root group id is always granted ping init when
CONFIG_SYSCTL is not set. It's more cautious than serious.

-- 
Ueimor
