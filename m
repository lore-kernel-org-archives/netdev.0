From: Michal Soltys <soltys@ziu.info>
Subject: Re: Question about HFSC atm+man patches
Date: Tue, 25 Nov 2008 00:21:01 +0100
Message-ID: <492B36DD.8010701@ziu.info>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net> <492AB29A.3010601@ziu.info> <492AB60A.9050606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:4210 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802AbYKXXw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 18:52:27 -0500
In-Reply-To: <492AB60A.9050606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> 
> qdisc_pkt_len already returns an adjusted length based on "size tables".
> Check out qdisc_enqueue()/qdisc_enqueue_root() for details.
> 
> Is there something missing for overhead calculation?

Thanks for pointing that out. It will fit well.

I'll have to wrap my head around the sources first though (even if the 
concept became even simpler now) - the patches for hfsc submitted in 
July along the ones for size tables, were a bit more extensive compared 
to what I've planned.
