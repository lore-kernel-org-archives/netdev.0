From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 2 Jun 2010 21:17:28 +0800
Message-ID: <AANLkTilTncCK6-_k-OXANJD-3wibhGGyUSyCJgbEOZXA@mail.gmail.com>
References: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
	<1275395667.3587.38.camel@bigi> <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	<1275481219.14363.6.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:60348 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868Ab0FBNRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:17:50 -0400
Received: by pvg16 with SMTP id 16so49723pvg.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:17:49 -0700 (PDT)
In-Reply-To: <1275481219.14363.6.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 2, 2010 at 8:20 PM, jamal <hadi@cyberus.ca> wrote:
>
> What i meant was if you can tell immediately what the maximum offset is
> then you dont need to go through for loop making comparison with each
> key. You could immediately bailout - which is an optimization ;->
>

I got it. But it isn't easy for me.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
