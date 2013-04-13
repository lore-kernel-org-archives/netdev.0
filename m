From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] fec: Fix PHC device log
Date: Sat, 13 Apr 2013 13:54:53 -0300
Message-ID: <CAOMZO5DfOXxZ5pgvgxgaKXgP0_XMvrfTUdMqMhMDFPLb4ZtsVQ@mail.gmail.com>
References: <1365871134-6834-1-git-send-email-festevam@gmail.com>
	<1365871779.2358.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:57903 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab3DMQyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 12:54:54 -0400
Received: by mail-ve0-f172.google.com with SMTP id db10so296792veb.17
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 09:54:53 -0700 (PDT)
In-Reply-To: <1365871779.2358.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 13, 2013 at 1:49 PM, Joe Perches <joe@perches.com> wrote:

> Maybe better as:
>                 netdev_info(ndev, "registered PHC device %d\n", fep->dev_id);

In this case I get:

fec 2188000.ethernet (unregistered net_device): registered PHC device 0
