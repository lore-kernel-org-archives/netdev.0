From: Raz <raziebe@gmail.com>
Subject: what is the expeted performance from a dual port 10G card ?
Date: Fri, 28 Nov 2008 15:11:13 +0200
Message-ID: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:42845 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbYK1NLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 08:11:15 -0500
Received: by an-out-0708.google.com with SMTP id d40so515407and.1
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2008 05:11:14 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I have been testing 10G ethernet cards , intel ixgbe, chelsio, tehuti
and melanox . All are dual port cards.
I have used pktgen to test it. A single cpu is mapped over a single
interface (no neeed for MQ , which is quite bad anyway).
Results:
Intel gives: 13Gbps , 6.5 from each port.
The rest give ~10 Gbps .
Cards were tested on PCI-E x8 slot, on a supermicro x7DBI and
supermicro 1025W-UR.

Am i to expect ~20Gbps from each card ?
Thank you.
