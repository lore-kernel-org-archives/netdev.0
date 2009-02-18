From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 40/43] drivers/net/wireless/ath9k: fix sparse warnings:
 Should it be static?
Date: Tue, 17 Feb 2009 19:35:46 -0800 (PST)
Message-ID: <20090217.193546.115478499.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214935.24377.69824.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754850AbZBRDgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:36:02 -0500
In-Reply-To: <20090214214935.24377.69824.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:49:48 +0100

> Impact: Make symbols static.
> 
> Fix this sparse warnings:
>   drivers/net/wireless/ath9k/eeprom.c:1343:5: warning: symbol 'ath9k_hw_4k_get_spur_channel' was not declared. Should it be static?
>   drivers/net/wireless/ath9k/eeprom.c:1372:19: warning: symbol 'eep_4k_ops' was not declared. Should it be static?
>   drivers/net/wireless/ath9k/eeprom.c:2649:5: warning: symbol 'ath9k_hw_def_get_spur_channel' was not declared. Should it be static?
>   drivers/net/wireless/ath9k/eeprom.c:2678:19: warning: symbol 'eep_def_ops' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
