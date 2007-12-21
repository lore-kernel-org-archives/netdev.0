From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Convert several length variable to unsigned.
Date: Fri, 21 Dec 2007 01:47:38 -0800 (PST)
Message-ID: <20071221.014738.97459348.davem@davemloft.net>
References: <20071221.164811.126977620.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752984AbXLUJri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:47:38 -0500
In-Reply-To: <20071221.164811.126977620.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 21 Dec 2007 16:48:11 +0900 (JST)

> Several length variables cannot be negative, so convert int to
> unsigned int.  This also allows us to do sane shift operations
> on those variables.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.25, thanks.
