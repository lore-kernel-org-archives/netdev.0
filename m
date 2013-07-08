From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Mon, 08 Jul 2013 13:00:09 -0700
Message-ID: <1373313609.4979.120.camel@edumazet-glaptop>
References: <1370332874-584-1-git-send-email-avagin@openvz.org>
	 <20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
	 <1373293036.4979.105.camel@edumazet-glaptop>
	 <20130708125748.2425c44d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36003 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab3GHUAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 16:00:11 -0400
Received: by mail-pa0-f42.google.com with SMTP id rl6so4768679pac.1
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 13:00:10 -0700 (PDT)
In-Reply-To: <20130708125748.2425c44d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 12:57 -0700, Stephen Hemminger wrote:

> Nevermind, original patch is fine since the set namespace (NR_setns) system
> call used did not show up into 3.0!

I was concerned by the ip batch facility, not the netns.
