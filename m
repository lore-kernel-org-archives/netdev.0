From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: return -EFAULT if copy_from_user() fails
Date: Fri, 10 Dec 2010 16:16:08 -0800 (PST)
Message-ID: <20101210.161608.63015391.davem@davemloft.net>
References: <20101210124009.GC10623@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756378Ab0LKAPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:15:40 -0500
In-Reply-To: <20101210124009.GC10623@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 10 Dec 2010 15:40:09 +0300

> We should be returning -EFAULT here.
> 
> Mostly this patch is to silence a smatch warning.  The upper levels
> of this driver turn all non-zero return values from isar_load_firmware()
> into 1.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
