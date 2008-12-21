From: "Timur Tabi" <timur@freescale.com>
Subject: Re: [PATCH 2/6] ucc_geth: Fix TX watchdog timeout handling
Date: Sat, 20 Dec 2008 21:19:23 -0600
Message-ID: <ed82fe3e0812201919o619fd7e7jb87bbec551caa4d@mail.gmail.com>
References: <20081218182326.GB30682@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>,
	"Li Yang" <leoli@freescale.com>,
	"Andy Fleming" <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: "Anton Vorontsov" <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:19702 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbYLUDTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2008 22:19:25 -0500
Received: by an-out-0708.google.com with SMTP id d40so536726and.1
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2008 19:19:23 -0800 (PST)
In-Reply-To: <20081218182326.GB30682@oksana.dev.rtsoft.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 12:23 PM, Anton Vorontsov
<avorontsov@ru.mvista.com> wrote:
> +static int ucc_geth_close(struct net_device *dev);
> +static int ucc_geth_open(struct net_device *dev);

I would prefer that you reorder the functions to eliminate the need
for forward references.

-- 
Timur Tabi
Linux kernel developer at Freescale
