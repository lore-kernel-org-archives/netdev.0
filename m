From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [BUG]  fs_enet not receiving multicast
Date: Wed, 7 Aug 2013 08:29:58 -0700
Message-ID: <20130807082958.49dd6458@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pantelis Antoniou <panto@intracom.gr>,
	Vitaly Bordug <vbordug@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50105 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab3HGPaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 11:30:03 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so2273539pab.6
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 08:30:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported on kernel bugzilla, freescale ethernet driver not
receiving multicast unless promiscuous enabled.

https://bugzilla.kernel.org/show_bug.cgi?id=60703
