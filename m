From: David Miller <davem@davemloft.net>
Subject: Re: dmfe/tulip device id overlap
Date: Sun, 29 Nov 2009 00:30:24 -0800 (PST)
Message-ID: <20091129.003024.245104886.davem@davemloft.net>
References: <20091125043603.GK14043@jenkins.home.ifup.org>
	<20091125044944.GL14043@jenkins.home.ifup.org>
	<da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brandon@ifup.org, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: grundler@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZK2IaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:30:20 -0500
In-Reply-To: <da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@google.com>
Date: Wed, 25 Nov 2009 09:24:54 -0800

> I'm ok with this patch except the mention of Ubuntu in the comment is
> superfluous. All the distro's will share this problem. I trust davem
> to rewrite the comment and plase add my:
>     Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

Please remove the comment and the __sparc__ ifdef.

If tulip doesn't work on some sparc systems we simply need to fix it.

Thanks.
