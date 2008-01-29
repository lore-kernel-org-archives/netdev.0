From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPV6] ADDRLABEL: Fix double free on label
 deletion.
Date: Mon, 28 Jan 2008 16:21:04 -0800 (PST)
Message-ID: <20080128.162104.132600552.davem@davemloft.net>
References: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753444AbYA2AUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 19:20:47 -0500
In-Reply-To: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 28 Jan 2008 21:02:22 +0900 (JST)

> If an entry is being deleted because it has only one reference, 
> we immediately delete it and blindly register the rcu handler for it,
> This results in oops by double freeing that object.
> 
> This patch fixes it by consolidating the code paths for the deletion;
> let its rcu handler delete the object if it has no more reference.
> 
> Bug was found by Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
