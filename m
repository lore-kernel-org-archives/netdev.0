From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: more fallout from sch locking changes?
Date: Mon, 20 Jun 2016 23:23:01 -0700
Message-ID: <1466490181.6850.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6bf6df76-4871-9408-a856-74410bdf7505@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34739 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbcFUGXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 02:23:05 -0400
Received: by mail-pf0-f179.google.com with SMTP id h14so3308977pfe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 23:23:04 -0700 (PDT)
In-Reply-To: <6bf6df76-4871-9408-a856-74410bdf7505@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-20 at 22:02 -0600, David Ahern wrote:
> I just updated to top of next-net tree (697666eac66) and still seeing an 
> occasional lockdep splat. It is not reliable to the point I would 
> attempt a git bisect. 2 splats -- 1 for ipv4 (first login to VM after 
> boot) and ipv6 (second login to VM after boot). Perhaps it is more 
> fallout of the packet scheduling changes you have been making this 
> iteration. Just a guess based on sch_direct_xmit in both traces.

Seems to be a lockdep hash chain collision, please report to lkml.
