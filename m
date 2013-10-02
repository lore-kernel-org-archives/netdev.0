From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Wed, 2 Oct 2013 12:33:33 +0200
Message-ID: <20131002103333.GB1528@minipsycho.brq.redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
 <20130930114343.GA6356@minipsycho.brq.redhat.com>
 <20130930172312.GE10771@order.stressinduktion.org>
 <20131001105837.GA1424@minipsycho.brq.redhat.com>
 <20131001120907.GH10771@order.stressinduktion.org>
 <20131001123214.GI10771@order.stressinduktion.org>
 <20131001214721.GJ10771@order.stressinduktion.org>
 <20131001232534.GM10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:37623 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab3JBKdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 06:33:38 -0400
Received: by mail-we0-f176.google.com with SMTP id u56so671271wes.7
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 03:33:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131001232534.GM10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
>On Tue, Oct 01, 2013 at 11:47:21PM +0200, Hannes Frederic Sowa wrote:
>> The strange thing is that if I don't do the IPV6_MTU setsockopt I don't
>> get an oops.
>
>This is incorrect, it just depends on the size of the writes and on the
>interface mtu.
>
>> IPv4 seems to work without problems, too.
>
>I also get kernel oopses from IPv4 now, too.

I'm not able to trigger this with ipv4. Can you please send strace
output for this as well?

Thanks
