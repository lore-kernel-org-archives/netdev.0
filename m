From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 net-next] af_unix: improve STREAM behavior with
 fragmented memory
Date: Sun, 11 Aug 2013 07:32:33 -0700
Message-ID: <1376231553.3291.0.camel@edumazet-glaptop>
References: <1375997852.4004.130.camel@edumazet-glaptop>
	 <20130811140605.GA5666@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Rientjes <rientjes@google.com>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:53157 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab3HKOch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 10:32:37 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so6575685pad.4
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 07:32:36 -0700 (PDT)
In-Reply-To: <20130811140605.GA5666@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-11 at 16:06 +0200, Hannes Frederic Sowa wrote:

> I am sorry to report that I had to revert both these patches to have a working
> systemd again.

Hi Hannes

If you revert only the second patch, the problem is still there, right ?
