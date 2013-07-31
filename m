From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v3 2/2] net: igmp: Allow user-space configuration of
 igmp unsolicited report interval
Date: Wed, 31 Jul 2013 01:07:37 -0400
Message-ID: <20130731010737.5e184786.billfink@mindspring.com>
References: <20130726163610.GF3890@order.stressinduktion.org>
	<1375107711-9029-1-git-send-email-william.manley@youview.com>
	<1375107711-9029-2-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org, hannes@stressinduktion.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com, davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:41671 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752988Ab3GaFNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 01:13:30 -0400
In-Reply-To: <1375107711-9029-2-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jul 2013, William Manley wrote:

> Adds the new procfs knobs:
> 
>     /proc/sys/net/ipv4/conf/*/igmpv2_unsolicited_report_interval
>     /proc/sys/net/ipv4/conf/*/igmpv3_unsolicited_report_interval
> 
> Which will allow userspace configuration of the IGMP unsolicited report
> interval (see below) in milliseconds.  The default 1000ms for IGMPv2 and
> 10000 for IGMPv3 in accordance with RFC2236 and RFC3376.

You have the 1000/10000 ms for IGMPv2/IGMPv3 flipped in your
commit message above.

					-Bill
