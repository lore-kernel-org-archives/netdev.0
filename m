From: "Zhang, Sonic" <Sonic.Zhang@analog.com>
Subject: RE: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet transmission when polling with KGDB
Date: Sun, 31 May 2009 10:45:44 +0800
Message-ID: <0F1B54C89D5F954D8535DB252AF412FA041F17C1@chinexm1.ad.analog.com>
References: <8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com><20090529.035224.124353374.davem@davemloft.net><8bd0f97a0905290420g454c3affr21b6f05e5971d93@mail.gmail.com> <20090529.042726.135473158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>, <cooloney@kernel.org>
To: "David Miller" <davem@davemloft.net>, <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:54907 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbZEaCow convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 22:44:52 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20090529.042726.135473158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems the position of the SSYNC should be put to several lines below.

Sonic 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, May 29, 2009 7:27 PM
To: vapier.adi@gmail.com
Cc: netdev@vger.kernel.org; uclinux-dist-devel@blackfin.uclinux.org;
Zhang, Sonic; cooloney@kernel.org
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
transmission when polling with KGDB

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 07:20:18 -0400

> that isnt how the DMA is being used here.  there is no register to 
> read back because the DMA controller is doing the reading indirectly.
> but along those lines, it's not entirely clear which DMA registers 
> this SSYNC is supposed to be protecting because all of the updates are

> happening on the descriptors in external memory, not the DMA registers

> themselves.  i'll have Sonic clarify.

Yes, that's really confusing because the commit message says
"registers".
