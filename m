From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] depca: fix leaks in depca_module_init()
Date: Mon, 12 Jul 2010 20:32:03 -0700 (PDT)
Message-ID: <20100712.203203.137829316.davem@davemloft.net>
References: <1278678986-7725-1-git-send-email-segooon@gmail.com>
	<20100711.181300.58435799.davem@davemloft.net>
	<20100712145233.GA30504@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	joe@perches.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751399Ab0GMDbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:31:48 -0400
In-Reply-To: <20100712145233.GA30504@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Mon, 12 Jul 2010 18:52:33 +0400

> Since some of xxx_register_driver() can return error we must unregister
> already registered drivers.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
