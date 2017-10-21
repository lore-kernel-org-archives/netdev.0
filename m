From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2017-10-19
Date: Sat, 21 Oct 2017 02:30:53 +0100 (WEST)
Message-ID: <20171021.023053.2108266801345662025.davem@davemloft.net>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46336 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753016AbdJUBa4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 21:30:56 -0400
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 19 Oct 2017 13:19:34 +0200

> this is a pull request of 11 patches for the upcoming 4.14 release.
> 
> There are 6 patches by ZHU Yi for the flexcan driver, that work around
> the CAN error handling state transition problems found in various
> incarnations of the flexcan IP core.
> 
> The patch by Colin Ian King fixes a potential NULL pointer deref in the
> CAN broad cast manager (bcm). One patch by me replaces a direct deref of a RCU
> protected pointer by rcu_access_pointer. My second patch adds missing
> OOM error handling in af_can. A patch by Stefan Mätje for the esd_usb2
> driver fixes the dlc in received RTR frames. And the last patch is by
> Wolfgang Grandegger, it fixes a busy loop in the gs_usb driver in case
> it runs out of TX contexts.

Pulled, thanks.
