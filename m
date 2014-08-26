From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC PATCH net-next] ipv6: stop sending PTB packets for MTU < 1280
Date: Tue, 26 Aug 2014 10:06:03 +0200
Message-ID: <CAPh34me0MTgr_RDsZt+3tCZQaoKWk+dRsyt_Mj0fENFPS_GF_w@mail.gmail.com>
References: <53F39E50.1020209@gont.com.ar>
	<1409005545-24910-2-git-send-email-hagen@jauu.net>
	<1409006842.6274.69.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Fernando Gont <fgont@si6networks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:56932 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932520AbaHZIGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 04:06:05 -0400
Received: by mail-lb0-f182.google.com with SMTP id n15so937963lbi.27
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 01:06:03 -0700 (PDT)
In-Reply-To: <1409006842.6274.69.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 August 2014 00:47, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

Hey Hannes

> I wonder if we should wait until this gets RFC status?

Yes, we should wait until we get Fernando's go (based on v6ops
discussion & consensus). But the discussions seem to boils down to
this action (remove IPv6 PTB generation < 1280). If so we probably
don't want to wait two years with an open "protocol bug".

> I very much welcome this decision! I already raised this problem some
> time ago:
> http://lists.openwall.net/netdev/2013/12/31/17

Thank you for the pointer

> I wonder if we should add a mode alike ipv4 ip_no_pmtu_disc mode for
> ipv6:

Not sure, we should discuss this here (netdev). I tend to remove the
functionality completely. Any use cases where it makes sense to keep
this?

> This patch is a starter, yes. We can now get rid of the dst_allfrag
> function altogether.

Yes right, I am aware of this. Depending on the discussion we should
get rid of the allfrags code or not. Let's see. Thank you Hannes for
the comments.

Hagen
