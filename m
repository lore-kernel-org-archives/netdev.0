From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: remove sk_init() helper
Date: Wed, 26 Sep 2012 04:23:25 +0200
Message-ID: <1348626205.26828.3563.camel@edumazet-glaptop>
References: <1348608733.26828.3492.camel@edumazet-glaptop>
	 <5062636E.2060200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41312 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab2IZCX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 22:23:29 -0400
Received: by wgbdr13 with SMTP id dr13so77592wgb.1
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 19:23:28 -0700 (PDT)
In-Reply-To: <5062636E.2060200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-26 at 10:07 +0800, Shan Wei wrote:
> Eric Dumazet said, at 2012/9/26 5:32:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > It seems sk_init() has no value today and even does strange things :
> > 
> > # grep . /proc/sys/net/core/?mem_*
> > /proc/sys/net/core/rmem_default:212992
> > /proc/sys/net/core/rmem_max:131071
> > /proc/sys/net/core/wmem_default:212992
> > /proc/sys/net/core/wmem_max:131071
> > 
> > We can remove it completely.
> 
> Ye, I have reported this problem.
> http://lists.openwall.net/netdev/2012/04/27/49
> 
> How about for small RAM ~16M?

It was maybe a concern 20 years ago, ( I ran linux on [34]86 computers
with 12 or 16 MB of memory) but this makes no sense today with linux-3.7
