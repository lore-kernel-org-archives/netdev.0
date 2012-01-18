From: Tore Anderson <tore@fud.no>
Subject: Re: Bugzilla 42595
Date: Wed, 18 Jan 2012 20:26:09 +0100
Message-ID: <4F171CD1.8070401@fud.no>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4F15D417.4050005@fud.no> <1326843827.2606.35.camel@edumazet-laptop>  <1326884311.2316.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1326894249.2316.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <8a6ad9cfd5afefc5617fc82203712f20@localhost>  <1326897726.2316.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1326901345.2316.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:59337 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011Ab2ART0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 14:26:11 -0500
In-Reply-To: <1326901345.2316.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet

> Following patch is a good compromise, since it disables gso on the
> socket on the first frame we consider too big in ip6_fragment().
> 
> So the added check on dst_allfrag() is only done once per socket,
> instead of adding in sk_can_gso(sk) in fast path.
> 
> I can now let gso on on the device, and still have good transfert speed
> on sockets hitting the ALLFRAG feature.

I can both confirm that I too saw abysmal performance when using the
default offload settings (with your two earlier patches applied only),
and also that applying this patch in addition fixes the problem, with no
apparent ill effects. Thanks!

Best regards,
-- 
Tore Anderson
