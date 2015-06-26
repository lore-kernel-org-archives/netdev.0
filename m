From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] ss: print value of IPV6_V6ONLY socket option
 if set
Date: Fri, 26 Jun 2015 00:18:29 -0400
Message-ID: <20150626001829.205b812c@uryu.home.lan>
References: <98d177c535aa4910b83df0b9856d80ab@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42169 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbbFZETD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 00:19:03 -0400
In-Reply-To: <98d177c535aa4910b83df0b9856d80ab@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Jun 2015 11:07:20 +0000
Phil Sutter <phil@nwl.cc> wrote:

> If available and set, print 'v6only:1' for AF_INET6 sockets upon request
> of extended information. For IPv6 sockets bound to in6addr_any, this is
> the only way to determine if they will also accept IPv4 requests or not.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Depends on unapplied patch 'ss: Include -E option for socket destroy
> events'
> 
> Kernel support patch: 204621551b2a0060a013b92f7add4d5c452fa7cb


Applied, currently staged on local net-next branch.
Will merge after 4.1 iproute2 release
