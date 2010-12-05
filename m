From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sun, 5 Dec 2010 08:22:35 +0800
Message-ID: <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <4CFA3F01.20109@gmail.com>
 <1291472889.2159.18.camel@mojatatu> <1291474127.2159.35.camel@mojatatu>
 <20101204154007.GA1981@del.dom.local> <1291478881.2159.70.camel@mojatatu> <20101204165609.GB1981@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56681 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab0LEAW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 19:22:56 -0500
Received: by fxm20 with SMTP id 20so3278267fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 16:22:55 -0800 (PST)
In-Reply-To: <20101204165609.GB1981@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 5, 2010 at 12:56 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
>
> I'm simply not convinced this kind of (fast) throttling can properly
> fix any of the problems (what about other flows in the queue), while
> Changli's patch makes this tasklet simpler and a bit faster.
>

The error case handled currently is the original netdev disappears but
the corresponding skbs are still in ifb.

I do also think checking the return value of netif_rx() and
dev_queue_xmit() can fix more 'problems'. :)

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
