From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: fix loop back of receive descriptors
Date: Mon, 19 Jan 2009 22:07:30 +0100
Message-ID: <200901192207.32649.florian@openwrt.org>
References: <20090115223005.D6F694043831@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:57656 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbZASVHk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:07:40 -0500
Received: by nf-out-0910.google.com with SMTP id d3so443107nfc.21
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 13:07:39 -0800 (PST)
In-Reply-To: <20090115223005.D6F694043831@mail.nwl.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thursday 15 January 2009 23:29:55 Phil Sutter, vous avez =E9crit=A0:
> After the last loop iteration, i has the value RC32434_NUM_RDS and
> therefore leads to an index overflow when used afterwards to address =
the
> last element. This is yet another another bug introduced when rewriti=
ng
> parts of the driver for upstream preparation, as the original driver
> used 'RC32434_NUM_RDS - 1' instead.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
