From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 02 Dec 2014 07:17:16 -0800
Message-ID: <1417533436.5303.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141202071304.GA22512@1wt.eu>
	 <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141202123951.GA16347@1wt.eu>
	 <1417525458.5303.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141202132412.GC16347@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:53562 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbaLBPRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 10:17:18 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so15107333igb.1
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 07:17:18 -0800 (PST)
In-Reply-To: <20141202132412.GC16347@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 14:24 +0100, Willy Tarreau wrote:

> Thanks but I'm not sure I entirely understand the concept. Is it to
> notify the sender that the packets were already queued for the NIC ?
> And if so, how does that improve the situation ? I'm sorry if this
> sounds like a stupid question, it's just that the concept by itself
> is not clear to me.

http://lwn.net/Articles/454390/

BQL is first step to fight so called bufferbloat.

https://www.ietf.org/proceedings/86/slides/slides-86-iccrg-0.pdf
