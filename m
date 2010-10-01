From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 3)
Date: Thu, 30 Sep 2010 17:35:57 -0700 (PDT)
Message-ID: <20100930.173557.108787840.davem@davemloft.net>
References: <1285725095-9860-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: flameeyes@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784Ab0JAAfg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 20:35:36 -0400
In-Reply-To: <1285725095-9860-1-git-send-email-flameeyes@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Diego Elio Petten=F2 <flameeyes@gmail.com>
Date: Wed, 29 Sep 2010 03:51:35 +0200

> +		rc =3D put_user(amount, (int __user *)arg);
> +	}
> +		break;

Please put the break statement inside of the basic block.

The way you have it here the indentation looks not so nice.
