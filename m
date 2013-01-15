From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC net-next] ipv6 route: Do not attach neighbour on route.
Date: Tue, 15 Jan 2013 02:37:24 +0000 (UTC)
Message-ID: <kd2fd3$5cv$1@ger.gmane.org>
References: <50F463E5.7070206@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60110 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734Ab3AOChm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 21:37:42 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TuwPU-0003k0-Kw
	for netdev@vger.kernel.org; Tue, 15 Jan 2013 03:37:56 +0100
Received: from 14.205.39.94 ([14.205.39.94])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 03:37:56 +0100
Received: from xiyou.wangcong by 14.205.39.94 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 03:37:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2013 at 20:00 GMT, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:
> Not tested, just an RFC.
> Depends on previous new_neigh removal from netevent patch (sorry).
>  

Forgot to define __ipv6_neigh_lookup_noref()?
