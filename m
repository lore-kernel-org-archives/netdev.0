From: "jiangtao.jit" <jiangtao.jit@gmail.com>
Subject: special handling before ndo_start_xmit() been invoked
Date: Wed, 27 Jul 2011 18:48:37 +0800
Message-ID: <201107271848349537853@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jiangtao.jit" <jiangtao.jit@gmail.com>
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:35883 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124Ab1G0KtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 06:49:09 -0400
Received: by pzk37 with SMTP id 37so2515636pzk.1
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2011 03:49:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all:

in struct net_device
there is a function pointer    rx_handler_func_t __rcu	*rx_handler
it's very convenient to register a function in an externel module
and do some special handlings

so i think what about to add an tx_handler_func
before        ndo_start_xmit() been invoked
and do some special things before transmit

is it necessary or there is already some other better methods to achieve this goal ?
Thank you all

-------
2011-07-27 
jiangtao.jit 

