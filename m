From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]atl1c: fix spelling error
Date: Sun, 31 May 2009 21:51:40 -0700 (PDT)
Message-ID: <20090531.215140.214511212.davem@davemloft.net>
References: <12438220782521-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pyunyh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45531
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058AbZFAEvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 00:51:40 -0400
In-Reply-To: <12438220782521-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jie.yang@atheros.com>
Date: Mon, 1 Jun 2009 10:07:58 +0800

> Fix spelling error
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>
 ...
> @@ -1115,7 +1115,7 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
>  
>  	AT_READ_REG(hw, REG_TXQ_CTRL, &data);
>  	data &= ~TXQ_CTRL_EN;
> -	AT_WRITE_REG(hw, REG_TWSI_CTRL, data);
> +	AT_WRITE_REG(hw, REG_TXQ_CTRL, data);
>  
>  	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
>  		AT_READ_REG(hw, REG_IDLE_STATUS, &data);

A spelling error would occur on human language text.

That's not what this is.

The code is referring to the wrong register, so it's a bug not a
spelling error.

Please fix your commit message and resubmit.
