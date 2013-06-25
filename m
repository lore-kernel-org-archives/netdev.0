From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] fec: Add support for reading RMON registers
Date: Tue, 25 Jun 2013 14:32:32 -0300
Message-ID: <CAOMZO5D-8RiuGY_b7+Ct+cYfLGJdmQNbpoumCdDrUFQGC_HCdw@mail.gmail.com>
References: <1372135740-32311-1-git-send-email-cphealy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Ruslan Sushko <rsushko@gmail.com>, netdev@vger.kernel.org
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:48394 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3FYRcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 13:32:33 -0400
Received: by mail-ve0-f175.google.com with SMTP id da11so10478812veb.34
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 10:32:32 -0700 (PDT)
In-Reply-To: <1372135740-32311-1-git-send-email-cphealy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 25, 2013 at 1:49 AM, Chris Healy <cphealy@gmail.com> wrote:
> Add ethtool operation to read RMON registers.

These RMON registers do not exist on mcf5272, so you need to take this
into account.
