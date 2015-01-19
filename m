From: "Harout Hedeshian" <harouth@codeaurora.org>
Subject: RE: [PATCH v2 net-next] net: ipv6: Add sysctl entry to disable MTU updates from RA
Date: Mon, 19 Jan 2015 15:42:08 -0700
Message-ID: <001501d03439$28f6d670$7ae48350$@codeaurora.org>
References: <1421703363-3376-1-git-send-email-harouth@codeaurora.org> <54BD80D6.40402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Daniel Borkmann'" <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:60451 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbbASWmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 17:42:10 -0500
In-Reply-To: <54BD80D6.40402@redhat.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Daniel Borkmann
> Sent: Monday, January 19, 2015 3:11 PM
> To: Harout Hedeshian
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH v2 net-next] net: ipv6: Add sysctl entry to disable
MTU
> updates from RA
> 
> On 01/19/2015 10:36 PM, Harout Hedeshian wrote:
> ...
> > diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
> > index 0956373..45e4fcf 100644
> > --- a/include/uapi/linux/sysctl.h
> > +++ b/include/uapi/linux/sysctl.h
> > @@ -570,6 +570,7 @@ enum {
> >   	NET_IPV6_PROXY_NDP=23,
> >   	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> >   	NET_IPV6_ACCEPT_RA_FROM_LOCAL=26,
> > +	NET_IPV6_ACCEPT_RA_MTU=27,
> >   	__NET_IPV6_MAX
> >   };
> >
> > diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c index
> > 7e7746a..16091e5 100644
> > --- a/kernel/sysctl_binary.c
> > +++ b/kernel/sysctl_binary.c
> > @@ -523,6 +523,7 @@ static const struct bin_table
> bin_net_ipv6_conf_var_table[] = {
> >   	{ CTL_INT,	NET_IPV6_PROXY_NDP,
> 	"proxy_ndp" },
> >   	{ CTL_INT,	NET_IPV6_ACCEPT_SOURCE_ROUTE,
> 	"accept_source_route" },
> >   	{ CTL_INT,	NET_IPV6_ACCEPT_RA_FROM_LOCAL,
> 	"accept_ra_from_local" },
> > +	{ CTL_INT,	NET_IPV6_ACCEPT_RA_MTU,
> 	"accept_ra_mtu" },
> >   	{}
> >   };
> 
> Hm, afaik, the binary sysctl interface is deprecated and nothing should be
> adding entries there anymore. I believe you copied this over from commit
> d9333196572 ("ipv6: Allow accepting RA from local IP addresses.")? :/

Hi Daniel,

Indeed, the patch is based on previous modifications to add sysctl/proc
entries for IPv6 parameters. It is done this way to maintain consistency. Do
you think we need a v3 without the changes to the sysctl_binary.c and
corresponding changes in includes/uapi?

d9333196572 ("ipv6: Allow accepting RA from local IP addresses.") is as
recent as June 2014.

Thanks,
Harout

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
