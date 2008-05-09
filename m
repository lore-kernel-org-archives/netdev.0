From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [NIU] Redo the fix for getting # of ports from
 EEPROM
Date: Thu, 08 May 2008 17:25:13 -0700 (PDT)
Message-ID: <20080508.172513.01395291.davem@davemloft.net>
References: <482398E3.9000206@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753518AbYEIAZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 20:25:19 -0400
In-Reply-To: <482398E3.9000206@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Thu, 08 May 2008 17:20:51 -0700

> @@ -8000,6 +7990,11 @@ static int __devinit niu_get_of_props(struct niu *np)
> 
>   	memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);
> 
> +	model = of_get_property(dp, "model", &prop_len);
> +
> +	if (model)
> +	  strcpy(np->vpd.model, model);
> +

Please fix the indentation in cases like this.  There should
be two tab characters in front of the strcpy().

I don't know what editor you use, but in emacs the editor
can take care of this automatically for you by simply typing
"M-x c-set-style RET linux RET"

I've been fixing up these coding style issues for you in the past, and
I've had to do so for every single patch you send me.  Unfortunately,
it's consuming a lot of my time and I'm not going to do it any more.

Therefore, please have a read up of:

	linux/Documentation/CodingStyle

which should help you in this area.  But generally, if you follow the
existing conventions in the rest of the niu.[ch] files you'll be OK
;-)

Another thing I noticed you do is put two blank lines between
functions, please only use one.

Please also write a full changelog description so people can
understand what you are doing here.

Thank you.
