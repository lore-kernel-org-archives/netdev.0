From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next-2.6] typhoon: fix a race in typhoon_do_get_stats
Date: Tue, 24 Aug 2010 10:52:33 -0400
Message-ID: <1282661553.25666.17.camel@lap75545.ornl.gov>
References: <1282659493.2477.241.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute3.ornl.gov ([160.91.4.110]:43149 "EHLO emroute3.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241Ab0HXPAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 11:00:20 -0400
Received: from emroute3.ornl.gov ([127.0.0.1])
 by emroute3.ornl.gov (PMDF V6.5-x1 #31823)
 with ESMTP id <0L7N00JDKVZN4B@emroute3.ornl.gov> for netdev@vger.kernel.org;
 Tue, 24 Aug 2010 10:52:36 -0400 (EDT)
In-reply-to: <1282659493.2477.241.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-24 at 16:18 +0200, Eric Dumazet wrote:
> Its important to store 'final' values in counters,
> not using them as temporary variables,
> or this might break some SNMP applications.

Acked-by: David Dillow <dave@thedillows.org>
