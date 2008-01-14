From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH]drivers/net/phy/: default return value in ioctl phy.c
Date: Mon, 14 Jan 2008 12:48:21 -0600
Message-ID: <E7E3FE26-AD70-4660-9D5E-7A6FCEC67127@freescale.com>
References: <014901c83c06$da9223e0$2b00a8c0@ARV127>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Rini van Zetten <rini@arvoo.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:63902 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbYANSsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 13:48:38 -0500
In-Reply-To: <014901c83c06$da9223e0$2b00a8c0@ARV127>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 11, 2007, at 09:02, Rini van Zetten wrote:

> Hello Andy,
>
> This patch (to 2.6.23.9) add a default return value EOPNOTSUPP to  
> the ioctl function. The problem with the always 0 return value is  
> that the iwconfig (wireless) tool found a valid device when an  
> ethernet device uses the phy abstraction layer.
> I 've tetsted this with the macb driver.
>
>
> Signed-off-by: Rini van Zetten <rini@arvoo.nl>

Acked-by: Andy Fleming <afleming@freescale.com>
