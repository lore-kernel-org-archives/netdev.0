From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] get_rate: detect 32bit overflows
Date: Sun, 02 Jun 2013 14:30:38 -0700
Message-ID: <1370208638.24311.87.camel@edumazet-glaptop>
References: <1370199083.24311.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33958 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3FBVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 17:30:40 -0400
Received: by mail-pd0-f171.google.com with SMTP id z11so4741119pdj.30
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 14:30:39 -0700 (PDT)
In-Reply-To: <1370199083.24311.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 11:51 -0700, Eric Dumazet wrote:
> Current rate limit is 34.359.738.360 bit per second, and
> unfortunately 40Gbps links are above it.
> 
> overflows in get_rate() are currently not detected, and some
> users are confused. Let's detect this and complain.
> 
> Note that some qdisc are ready to get extended range, but this will
> need additional attributes and new iproute2
> 

Hmpf, patch is buggy, I'll send a v2
