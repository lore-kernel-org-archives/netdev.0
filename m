From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: udp v6 early demux?
Date: Tue, 10 Feb 2015 20:57:05 -0800
Message-ID: <1423630625.4847.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54DA3C64.1060309@gmail.com>
	 <1423589555.28434.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54DAC43C.2090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:44015 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbbBKE5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 23:57:08 -0500
Received: by pdev10 with SMTP id v10so1802484pde.10
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 20:57:07 -0800 (PST)
In-Reply-To: <54DAC43C.2090101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 21:53 -0500, Vlad Yasevich wrote:

> I was more wondering if we can avoid the route the lookup.  It may not always be
> a connected a case.  If you have multiple senders and a single receiver on the
> same subnet, avoiding the route lookup with early demux might help.

Yes, but early demux requires a connected socket, sorry.
