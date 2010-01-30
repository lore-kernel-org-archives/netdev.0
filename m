From: Susant Sahani <ssahani@gmail.com>
Subject: nf_reinject crashes after NF_STOLEN
Date: Sat, 30 Jan 2010 12:39:16 +0530
Message-ID: <d81115a61001292309y48cfa9c9u34455269f9597d37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:62560 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab0A3HJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 02:09:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
       If NF_STOLEN is done then how to reinsert the packet after sometime.

Here is the scenario.

packet1 comes in store return NF_STOLEN
packet2 comes in store return NF_STOLEN
packet3 comes in store return NF_STOLEN
packet4 comes in reinsert All the packets (packet1, packet2, packet3,
packet4) to IP stack so that it can continue the journey.

But if I do nf_reinject it crashes.

Please let me know how to do it.

susant
