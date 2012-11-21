From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: Bonding driver does not consider the
 gso_max_size setting of slaves.
Date: Wed, 21 Nov 2012 06:44:47 -0800
Message-ID: <1353509087.2590.32.camel@edumazet-glaptop>
References: <8814d83f-7213-4a32-91ec-39088a1a60a6@CMEXHTCAS1.ad.emulex.com>
	 <20121121115601.GA5579@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sarveshwar.bandi@emulex.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:57840 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809Ab2KUOot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 09:44:49 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so5075712iay.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 06:44:49 -0800 (PST)
In-Reply-To: <20121121115601.GA5579@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 06:56 -0500, Neil Horman wrote:

> This seems a bit overly complex.  It doesn't seem like you need the
> reset_go_size bool in here at all.  Just initalize gso_max_size to GSO_MAX_SIZE
> and reduce it every time you find a smaller gso value on a slave.  Then you can
> unilaterally set the bond devices gso_max_size without having to check any bools
> or do any comparisons.

Oh well, I should have read your answer ;)
