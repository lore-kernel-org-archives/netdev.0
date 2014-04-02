From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: ti: fix CPTS driver build on arm
Date: Wed, 02 Apr 2014 08:22:38 +0200
Message-ID: <533BACAE.3060603@redhat.com>
References: <1396402008-3462-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756577AbaDBGWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2014 02:22:45 -0400
In-Reply-To: <1396402008-3462-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2014 03:26 AM, Alexei Starovoitov wrote:
> fix build errors:
> drivers/net/ethernet/ti/cpts.c:266:12: error: 'ETH_HLEN' undeclared (first use in this function)
> drivers/net/ethernet/ti/cpts.c:276:23: error: 'VLAN_HLEN' undeclared (first use in this function)
>
> Fixes: 408eccce3204 ("net: ptp: move PTP classifier in its own file")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Richard Cochran <richardcochran@gmail.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

Thanks, should have set up an ARM toolchain :/ (allmodconfig on x86_64 was fine).
