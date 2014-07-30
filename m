From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: fill the magic in bnad_get_eeprom() instead
 of validating
Date: Wed, 30 Jul 2014 13:57:00 -0700 (PDT)
Message-ID: <20140730.135700.299027446890188381.davem@davemloft.net>
References: <1406552632-1201-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbaG3U5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 16:57:00 -0400
In-Reply-To: <1406552632-1201-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Mon, 28 Jul 2014 15:03:52 +0200

> A driver should fill magic field of ethtool_eeprom struct in .get_eeprom
> and validate it in .set_eeprom. The bna incorrectly validates it in both
> and this makes its .get_eeprom interface unusable.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thank you.
