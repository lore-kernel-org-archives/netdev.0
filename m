From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] nstat: 64bit support on 32bit arches
Date: Mon, 25 Aug 2014 15:52:54 -0700
Message-ID: <1409007174.3173.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408976874.5604.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140825144808.25459645@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:42000 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933601AbaHYWwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:52:55 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so21677488pad.8
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 15:52:55 -0700 (PDT)
In-Reply-To: <20140825144808.25459645@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-25 at 14:48 -0700, Stephen Hemminger wrote:

> 
> Maybe time to convert to using uint64_t and the printf formats in inttypes.h

Yes, that would be a cleanup, but end result is quite ugly if you ask
me.
