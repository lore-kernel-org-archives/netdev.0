From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH][XFRM][0/5] extension for XFRM databases
Date: Thu, 01 Feb 2007 08:24:33 -0500
Message-ID: <1170336273.3915.12.camel@localhost>
References: <20070201114339.E2BD.SHINTA@sfc.wide.ad.jp>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:42433 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422865AbXBANYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 08:24:36 -0500
Received: by wr-out-0506.google.com with SMTP id 68so498645wri
        for <netdev@vger.kernel.org>; Thu, 01 Feb 2007 05:24:36 -0800 (PST)
In-Reply-To: <20070201114339.E2BD.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I think i may have understood your approach before but i am a little
lost right now, so bear with me.

Could we not achieve your goals by using (on XFRM at least)
XFRM_MSG_UPDPOLICY  and XFRM_MSG_UPDSA ?

cheers, 
jamal

On Thu, 2007-01-02 at 13:09 +0900, Shinta Sugimoto wrote:
> Hello,
> 
> Let me issue a request for comments for the patch set developed by
> the USAGI project.  The patch set aims to extend the XFRM framework
> so that endpoint addresses in the XFRM databases, namely Could XFRM policy
> and XFRM state can be dynamically updated according to a request from
> user application.  This feature is required for Mobile IPv6 to follow
> the security requirements specified in RFC3776.  More specifically,
> the Mobile Node and Home Agent need to update the endpoint addresses
> of the IPsec tunnel when the Mobile Node changes its attachment point
> (Care-of Address) to the Internet.  The kernel also notifies userland
> application via both Netlink and PF_KEY sockets so that user application
> (e.g. IKE Daemon) could be informed of the updates appropriately.
> More detailed information of motivation/rationale for this feature
> can be found in the internet draft[1].
> 
> The patch set consists of following patches:
> 
> [1/5] [XFRM]: Extension to the XFRM framework for dynamic update of endpoint address(es)
> [2/5] [XFRM]: User interface for handling XFRM_MSG_MIGRATE
> [3/5] [XFRM]: CONFIG_XFRM_MIGRATE option
> [4/5] [PFKEYV2]: Extension to the PF_KEYv2 framework for dynamic update of endpoint address(es)
> [5/5] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option
> 
> Any comments/suggestions are appreciated.
> Thank you very much.
> 
> [1]: http://www.ietf.org/internet-drafts/draft-sugimoto-mip6-pfkey-migrate-03.txt
> 
> 
> Regards,
> Shinta
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

