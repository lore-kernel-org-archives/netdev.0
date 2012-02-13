From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/2] bluetooth: Use more current logging styles
Date: Mon, 13 Feb 2012 07:35:13 +0100
Message-ID: <1329114913.28848.50.camel@aeonflux>
References: <cover.1329102581.git.joe@perches.com>
	 <44b8744770a55924c68f8ad0ca274816d2d6148f.1329102581.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40693 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab2BMGh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 01:37:28 -0500
In-Reply-To: <44b8744770a55924c68f8ad0ca274816d2d6148f.1329102581.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

> Make functions for bt_info and bt_err.
> Remove now unused function bt_printk.
> Convert uses of BT_INFO and BT_ERR to bt_info and bt_err.

That is all fine, but why not just change BT_INFO to point to bt_info
and BT_ERR to bt_err first instead of having this huge patch mixed in
with the changes. The size measurement should be no different.

> Add newlines to uses of bt_info and bt_err.

Why is this a good thing?

And in your patch we have bt_err not having \n\n in the end.

> Align arguments and coalesce formats.

Again, I am not a huge fan to squeeze this all in one patch.

> Reduces object sizes a small amount.
> (defconfig with bluetooth on and all bluetooth drivers)
> 
> $ size net/bluetooth/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  380796	  20072	 100200	 501068	  7a54c	net/bluetooth/built-in.o.allyesconfig.new
>  381595	  20072	 100184	 501851	  7a85b	net/bluetooth/built-in.o.allyesconfig.old
>  126328	   1388	    132	 127848	  1f368	net/bluetooth/built-in.o.defconfig.new
>  126883	   1388	    132	 128403	  1f593	net/bluetooth/built-in.o.defconfig.old
> 
> $ size drivers/bluetooth/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  127606	   8956	  29484	 166046	  2889e	drivers/bluetooth/built-in.o.allyesconfig.new
>  129540	   8956	  29524	 168020	  29054	drivers/bluetooth/built-in.o.allyesconfig.old
>   53033	   3260	    156	  56449	   dc81	drivers/bluetooth/built-in.o.defconfig.new
>   54390	   3260	    156	  57806	   e1ce	drivers/bluetooth/built-in.o.defconfig.old

Size numbers look good. So I am all for this, but not just in one big
patch.

Regards

Marcel
