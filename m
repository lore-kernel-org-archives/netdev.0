From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: interrupt coalescing and CSUM offload
Date: Fri, 14 Sep 2012 16:35:13 +0200
Message-ID: <OF3E0CDC2E.8FFEBDC0-ONC1257A79.004A2EB6-C1257A79.00502122@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:57698 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105Ab2INOfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 10:35:16 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 77738258137
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 16:35:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am adding interrupt coalescing to the ucc_geth driver. Unfortunately
there is only support for RX interrupt coalescing.
I wonder if there is any way "simulate" TX interrupt coalescing?

I am also looking at adding HWCSUM support but this device can only do
IP header CSUM offload. This doesn't seem to be an option in Linux?
As I understand it, one must do CSUM offload for the whole frame, both
IP header and TCP/UDP csums?

 Jocke
