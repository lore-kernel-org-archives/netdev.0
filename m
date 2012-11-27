From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: performance regression on HiperSockets depending on MTU size
Date: Mon, 26 Nov 2012 22:46:40 -0800
Message-ID: <1353998800.7553.873.camel@edumazet-glaptop>
References: <20121126153242.GA61652@tuxmaker.boeblingen.de.ibm.com>
	 <1353946351.30446.1779.camel@edumazet-glaptop> <k91m5l$77a$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53290 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732Ab2K0Gqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 01:46:42 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so7712625iea.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 22:46:42 -0800 (PST)
In-Reply-To: <k91m5l$77a$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 06:21 +0000, Cong Wang wrote:

> Eric,
> 
> Do you have a full list of such commits? I am trying to backport TSQ
> to 2.6.32, and of course I don't want to miss these commits either.

I dont think there are other known issues.

mlx4 had a 'problem' because only recently we removed the skb_orphan()
call it used to do in its start_xmit() function.

I remember David had to revert BQL on NIU driver, but NIU does the
skb_orphan() call as well so TSQ is basically disabled.
