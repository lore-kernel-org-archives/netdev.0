From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 2/2] net: igmp: Allow user-space configuration of igmp unsolicited report interval
Date: Wed, 31 Jul 2013 08:34:42 +0200
Message-ID: <20130731063442.GA10498@order.stressinduktion.org>
References: <1375107711-9029-1-git-send-email-william.manley@youview.com> <1375107711-9029-2-git-send-email-william.manley@youview.com> <20130730061426.GF2490@order.stressinduktion.org> <20130730.165557.1185057462473078021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: william.manley@youview.com, netdev@vger.kernel.org, bcrl@kvack.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:50148 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3GaGeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 02:34:44 -0400
Content-Disposition: inline
In-Reply-To: <20130730.165557.1185057462473078021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 04:55:57PM -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 30 Jul 2013 08:14:26 +0200
> 
> > On Mon, Jul 29, 2013 at 03:21:51PM +0100, William Manley wrote:
> >> @@ -2099,6 +2103,10 @@ static struct devinet_sysctl_table {
> >>  		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
> >>  		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
> >>  					      "force_igmp_version"),
> >> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV2_UNSOLICITED_REPORT_INTERVAL,
> >> +					      "igmpv2_unsolicited_report_interval"),
> >> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
> >> +					      "igmpv3_unsolicited_report_interval"),
> >>  		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
> >>  					      "promote_secondaries"),
> >>  		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
> > 
> > Why did you use DEVINET_SYSCTL_FLUSHING_ENTRY here? Wouldn't
> > DEVINET_SYSCTL_RW_ENTRY be a better choice?
> 
> Agreed, there is no reason to flush the routing cache just because
> the igmp unsolicited report interval changed.

William, could you convert force_igmp_version to DEVINET_SYSCTL_RW_ENTRY as
well when you send a new patch?

Thanks,

  Hannes
