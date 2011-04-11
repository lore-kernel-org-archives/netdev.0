From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] caif: Add CAIF HSI Link Layer
Date: Mon, 11 Apr 2011 13:08:44 -0700 (PDT)
Message-ID: <20110411.130844.183063120.davem@davemloft.net>
References: <1302552320-11549-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linus.walleij@stericsson.com,
	sjurbren@gmail.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52634
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755751Ab1DKUJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:09:20 -0400
In-Reply-To: <1302552320-11549-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Mon, 11 Apr 2011 22:05:20 +0200

> I've made cfhsi_tx_frm lock protected (by moving some spin_unlock)
> and added a WARN_ON(!spin_is_locked(...)) to be safe.

spin_is_locked() always returns false on uniprocessor builds.
