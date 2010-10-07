From: David Miller <davem@davemloft.net>
Subject: Re: [patch] eicon: make buffer larger
Date: Wed, 06 Oct 2010 23:30:52 -0700 (PDT)
Message-ID: <20101006.233052.233715980.davem@davemloft.net>
References: <20101004192459.GE5692@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755131Ab0JGGab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:30:31 -0400
In-Reply-To: <20101004192459.GE5692@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 4 Oct 2010 21:24:59 +0200

> In diva_mnt_add_xdi_adapter() we do this:
>   strcpy (clients[id].drvName,     tmp);
>   strcpy (clients[id].Dbg.drvName, tmp);
> 
> The "clients[id].drvName" is a 128 character buffer and
> "clients[id].Dbg.drvName" was originally a 16 character buffer but I've
> changed it to 128 as well.  We don't actually use 128 characters but we
> do use more than 16.
> 
> I've also changed the size of "tmp" to 128 characters instead of 256.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
