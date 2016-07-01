From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH] ip route: timeout for routes has to be set in seconds
Date: Thu, 30 Jun 2016 17:29:22 -0700
Message-ID: <20160630172922.2e9efbcb@xeon-e3>
References: <5a205385ce594320936c4e330d52f532@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Vagin <avagin@virtuozzo.com>,
	Xin Long <lucien.xin@gmail.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46479 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751994AbcGAAbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 20:31:07 -0400
In-Reply-To: <5a205385ce594320936c4e330d52f532@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2016 23:27:14 +0000
Andrey Vagin <avagin@openvz.org> wrote:

> From: Andrew Vagin <avagin@virtuozzo.com>
> 
> Currently a timeout is multiplied by HZ in user-space and
> then it multiplied by HZ in kernel-space.
> 
> $ ./ip/ip r add 2002::0/64 dev veth1 expires 10
> $ ./ip/ip -6 r
> 2002::/64 dev veth1  metric 1024 linkdown  expires 996sec pref medium
> 
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: Hangbin Liu <liuhangbin@gmail.com>
> Cc: Stephen Hemminger <shemming@brocade.com>
> Fixes: 68eede250500 ("route: allow routes to be configured with expire values")
> Signed-off-by: Andrew Vagin <avagin@virtuozzo.com>

Applied.
