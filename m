From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] route: filter routes by family if it's
 specified
Date: Wed, 23 Sep 2015 16:16:51 -0700
Message-ID: <20150923161651.771ba259@urahara>
References: <35fe2442e87b4e91a7b4ff16739ba216@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33865 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137AbbIWXQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:16:40 -0400
Received: by padhy16 with SMTP id hy16so53452338pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:16:39 -0700 (PDT)
In-Reply-To: <35fe2442e87b4e91a7b4ff16739ba216@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 11:43:46 +0000
Andrey Vagin <avagin@openvz.org> wrote:

> From: Andrew Vagin <avagin@openvz.org>
> 
> Currently when we specify AF_INET6 when it is disabled, we will get
> all routes.
> 
> For example, we can boot kernel with ipv6.disable=1 and try to get ipv6
> routes:
> $ ip -6 route show
> default via 192.168.122.1 dev eth0  proto static  metric 100
> 192.168.122.0/24 dev eth0  proto kernel  scope link  src 192.168.122.141  metric 100
> 
> Here are ipv4 routes and this is unexpected behaviour.
> 
> Signed-off-by: Andrew Vagin <avagin@openvz.org>

Applied thanks.
