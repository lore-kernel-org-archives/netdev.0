From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 09:48:39 -0400
Message-ID: <1275486519.3545.7.camel@bigi>
References: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	 <1275481219.14363.6.camel@bigi> <1275481538.14363.10.camel@bigi>
	 <20100602.054520.228955151.davem@davemloft.net>
	 <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
	 <1275485797.3545.4.camel@bigi>
	 <AANLkTilZt3mfYt1hcDUc4VpNT5NEYoiGrFVjpGPAZH7q@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:65305 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755062Ab0FBNsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:48:45 -0400
Received: by pwj2 with SMTP id 2so1692180pwj.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:48:45 -0700 (PDT)
In-Reply-To: <AANLkTilZt3mfYt1hcDUc4VpNT5NEYoiGrFVjpGPAZH7q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 21:43 +0800, Changli Gao wrote:

> Yea, pedit has the same issue. Besides this issue, they should use
> get_unaligned() instead.

sounds reasonable - although they are probably different patches with
the offset fix being more important.

cheers,
jamal

