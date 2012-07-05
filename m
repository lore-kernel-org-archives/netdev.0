From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 10:33:12 +0200
Message-ID: <1341477192.2583.3415.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:32782 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507Ab2GEIdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 04:33:17 -0400
Received: by eaak11 with SMTP id k11so3130105eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 01:33:16 -0700 (PDT)
In-Reply-To: <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 16:27 +0800, Ming Lei wrote:

> After some investigation, the problem is caused by enabling
> DEBUG_SLAB, so it is not a regression.
> 

Strange, unless your machine is a _very_ slow one maybe ?

> 
> Looks no improvement. I still don't know why the window size becomes so
> small even in good situation(disabling DEBUG_SLAB), and the small
> window size will cause almost every tcp data packet acked.

You are probably missing the fact that window scaling is enabled.

If you dont post a pcap, I am afraid we cant really help.
