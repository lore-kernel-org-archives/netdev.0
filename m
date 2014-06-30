From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet loss when txqueuelen is zero
Date: Sun, 29 Jun 2014 22:49:23 -0700
Message-ID: <1404107363.15139.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53AEA00F.6060500@lategoodbye.de>
	 <1403966418.15139.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53B019E5.4060905@lategoodbye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Stefan Wahren <info@lategoodbye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54075 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaF3Ft3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 01:49:29 -0400
Received: by mail-we0-f174.google.com with SMTP id u57so7676874wes.19
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 22:49:28 -0700 (PDT)
In-Reply-To: <53B019E5.4060905@lategoodbye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-29 at 15:51 +0200, Stefan Wahren wrote:

> But fq_codel requires BQL in the QCA7000 network driver. Right?

Not at all. 10 skb in TX ring is very small, BQL wont really help in
this case.

BQL is good for NIC with TSO support, mostly.
