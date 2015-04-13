From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 0/1] stmmac: rmmod oops after ifconfig on interface
Date: Mon, 13 Apr 2015 16:33:46 +0300
Message-ID: <CAHp75VckYS54tVjCoqLSNbgAa48h5+Vp4XGXV1qCmahxOYbEzQ@mail.gmail.com>
References: <1428923713-2419-1-git-send-email-pure.logic@nexus-software.ie>
	<CAHp75VfunOA4=x9y_XV2J7rLB=+fmkHJc+bm+fnGZWv7-ncLeQ@mail.gmail.com>
	<552BB695.9090508@nexus-software.ie>
	<552BC36F.3060809@nexus-software.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Bryan O'Donoghue" <pure.logic@nexus-software.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:33998 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbbDMNdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:33:47 -0400
Received: by lbcga7 with SMTP id ga7so58737347lbc.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 06:33:46 -0700 (PDT)
In-Reply-To: <552BC36F.3060809@nexus-software.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm... By some reason this didn't make mailing list.

On Mon, Apr 13, 2015 at 4:23 PM, Bryan O'Donoghue
<pure.logic@nexus-software.ie> wrote:
> Might be a bit of an issue getting you a 'fixes' tag - I can't bisect back
> in time very far - very soon we stop booting.
>
> Would you be happy with a fixes that indicates the original checkin
> sequenced the unregister_netdev(); and mdiobus_unreg() in the wrong order ?

I actually think David could help us in this.

> Basically the 'fixes' tag then would be 47dd7a540
> net: add support for STMicroelectronics Ethernet controllers.

I don't know how to proceed in such cases since the patch will
apparently not apply to that commit.

> This was a long standing bug in this driver since we started using in on
> Quark - completely slipped my mind until I encountered this bug for another
> reason recently.


-- 
With Best Regards,
Andy Shevchenko
