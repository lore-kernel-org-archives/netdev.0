From: Andrew Dickinson <andrew@whydna.net>
Subject: ixgbe: 82599 and Westmere with HT
Date: Wed, 16 Feb 2011 17:21:35 -0800
Message-ID: <AANLkTi=1d8aJoFU7gsNy-sYjJomGp-Xz4K+ddKSOk-ir@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56394 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab1BQBVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 20:21:36 -0500
Received: by fxm20 with SMTP id 20so2082167fxm.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 17:21:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got a dual Westmere board (X5675) with an X520 card with dual
10G.  I see 24-cores exposed to me and the ixgbe driver exposes 24 tx
and 24 rx interrupts per NIC.  I then pin the interrupts to cores for
each NIC (each interrupt gets its own core, standard stuff).

Anyway.... I'm only seeing RX interrupts on 16 of the 24 cores (random
src/dest pairs across a /16 each, so I should be getting good flow
hashing).  Did I miss some magic somewhere?

I'm running 2.6.32.4, perhaps this has been fixed upstream.  If not,
any thoughts on how to make this work?

-A
