From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/7] atm: [br2684] Fix oops due to skb->dev
 being NULL
Date: Mon, 16 Jun 2008 17:15:41 -0700 (PDT)
Message-ID: <20080616.171541.132082153.davem@davemloft.net>
References: <200806161726.m5GHQpV6003328@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751186AbYFQAPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:15:41 -0400
In-Reply-To: <200806161726.m5GHQpV6003328@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Mon, 16 Jun 2008 13:26:51 -0400

> please apply to net-2.6.
> 
> commit d1a3f097e4683798cc15c8306fa323bef40fe6a6
> Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
> Date:   Sat Jun 14 16:46:14 2008 -0400
> 
>     atm: [br2684] Fix oops due to skb->dev being NULL
>     
>     It happens that if a packet arrives in a VC between the call to open it on
>     the hardware and the call to change the backend to br2684, br2684_regvcc
>     processes the packet and oopses dereferencing skb->dev because it is
>     NULL before the call to br2684_push().
>     
>     Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied.
