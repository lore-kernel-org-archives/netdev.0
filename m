From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] net: igmp: Allow user-space configuration of igmp unsolicited report interval
Date: Fri, 26 Jul 2013 18:36:10 +0200
Message-ID: <20130726163610.GF3890@order.stressinduktion.org>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374754445-5608-1-git-send-email-william.manley@youview.com> <1374754445-5608-2-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41532 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab3GZQgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 12:36:12 -0400
Content-Disposition: inline
In-Reply-To: <1374754445-5608-2-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 01:14:05PM +0100, William Manley wrote:
> Adds a new procfs knob:
> 
>     /proc/sys/net/ipv4/conf/*/force_igmp_unsolicited_report_interval
> 
> Which will allow userspace configuration of the IGMP unsolicited report
> interval (see below) in milliseconds.  The default is -1 which means use
> default behaviour (10s for IGMPv3 and 1s for IGMPv2 in accordance with
> RFC2236 and RFC3376).

Hm, would it be easy to split the timers per protocol? It seems a bit
hackish to me.

Thanks,

  Hannes
