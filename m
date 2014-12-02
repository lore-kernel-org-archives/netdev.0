From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 02 Dec 2014 05:04:18 -0800
Message-ID: <1417525458.5303.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141202071304.GA22512@1wt.eu>
	 <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141202123951.GA16347@1wt.eu>
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
Received: from mail-ig0-f177.google.com ([209.85.213.177]:52665 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535AbaLBNEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 08:04:21 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so10689791igj.16
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 05:04:20 -0800 (PST)
In-Reply-To: <20141202123951.GA16347@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 13:39 +0100, Willy Tarreau wrote:
> Hi Eric,
> 
> On Tue, Dec 02, 2014 at 04:18:08AM -0800, Eric Dumazet wrote:
> 
> > I highly suggest BQL for this driver, now this issue is fixed.
> 
> How does that work ?

This works very well ;)

Its super easy to implement, take a look at commits
bdbc063129e811264cd6c311d8c2d9b95de01231 or
7070ce0a6419a118842298bc967061ad6cea40db
