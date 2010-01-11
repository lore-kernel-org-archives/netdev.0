From: Gerrit Binnenmars <gerritbinnenmars@online.nl>
Subject: Different MTU sizes on a single ethernet port
Date: Mon, 11 Jan 2010 19:39:39 +0100 (CET)
Message-ID: <1774498547.4264241263235179792.JavaMail.root@mailstore13>
References: <702058967.4264131263235085567.JavaMail.root@mailstore13>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp10.online.nl ([194.134.42.55]:33225 "EHLO smtp10.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750934Ab0AKSug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 13:50:36 -0500
Received: from smtp10.online.nl (localhost [127.0.0.1])
	by smtp10.online.nl (Postfix) with ESMTP id D773B401CC
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 19:39:39 +0100 (CET)
Received: from mailstore13.back.prod.mail.online.nl (mailstore13.back.prod.mail.online.nl [10.160.210.113])
	by smtp10.online.nl (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 19:39:39 +0100 (CET)
In-Reply-To: <702058967.4264131263235085567.JavaMail.root@mailstore13>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It seems that the following is not possible on Linux

Default ethernet port eth0   : MTU 1500
VLAN ethernet port    eth0.3 : MTU 9000

(Although you can do ifconfig eth0 mtu 9000; ifconfig eth0.3 mtu 9000; ifconfig eth0 mtu 1500)

To solve this the MTU size of the VLAN should be passed to the adapter, and the adapter should have a MTU size for its default interface and a MTU size which is the max. of all interfaces on this port.

Anyone been working on this before, or any other ideas how this can be achieved?

With regards,

Gerrit Binnenmars
