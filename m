From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 14:18:50 -0700
Message-ID: <20071005141850.0fdd0858@freepuppy.rosehill>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083924.4e7f5d59@freepuppy.rosehill>
	<20071005.141247.71101713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33545 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761873AbXJEVTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:19:35 -0400
In-Reply-To: <20071005.141247.71101713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 Oct 2007 14:12:47 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 5 Oct 2007 08:39:24 -0700
> 
> > Build failed on x86_64
> > 
> > ERROR: "__bad_udelay" [drivers/net/niu.ko] undefined!
> 
> Can you figure out which udelay() call is too big and
> thus causing problems?
--- a/drivers/net/niu.c	2007-10-05 08:09:31.000000000 -0700
+++ b/drivers/net/niu.c	2007-10-05 08:42:06.000000000 -0700
@@ -804,7 +804,7 @@ static int bcm8704_init_user_dev3(struct
 	if (err)
 		return err;
 
-	udelay(1000000);
+	mdelay(1000);
 
 	return 0;
 }


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
