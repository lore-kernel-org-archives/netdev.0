From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] iproute2: v4: Add support to configure SR-IOV VF
 minimum and maximum Tx rate through ip tool.
Date: Mon, 9 Jun 2014 12:54:08 -0700
Message-ID: <20140609125408.06026ad8@nehalam.linuxnetplumber.net>
References: <1400046935-13972-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	<ben@decadent.org.uk>, <gregory.v.rose@intel.com>,
	<linux-net-drivers@solarflare.com>, <Ariel.Elior@qlogic.com>,
	<amirv@mellanox.com>, <mkubecek@suse.cz>
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:52572 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773AbaFIT5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:57:18 -0400
Received: by mail-pd0-f179.google.com with SMTP id fp1so5244510pdb.38
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:57:17 -0700 (PDT)
In-Reply-To: <1400046935-13972-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 01:55:35 -0400
Sucheta Chakraborty <sucheta.chakraborty@qlogic.com> wrote:

> o "min_tx_rate" option has been added for minimum Tx rate. Hence, for
>   consistent naming, "max_tx_rate" option has been introduced for maximum
>   Tx rate.
> 
> o Change in v2: "rate" can be used along with "max_tx_rate".
>   When both are specified, "max_tx_rate" should override.
> 
> o Change in v3:
>   * IFLA_VF_RATE: When IFLA_VF_RATE is used, and user has given only one of
>     min_tx_rate or max_tx_rate, reading of previous rate limits is done in
>     userspace instead of in kernel space before ndo_set_vf_rate.
> 
>   * IFLA_VF_TX_RATE: When IFLA_VF_TX_RATE is used, min_tx_rate is always read
>     in kernel space. This takes care of below scenarios:
>     (1) when old tool sends "rate" but kernel is new (expects min and max)
>     (2) when new tool sends only "rate" but kernel is old (expects only "rate")
> 
> o Change in v4 as suggested by Stephen Hemminger:
>   * As per iproute policy, input and output formats should match. Changing display
>     of max_tx_rate and min_tx_rate options accordingly.
> 	./ip/ip link show p3p1
> 	8: p3p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
>         link/ether 00:0e:1e:16:ce:40 brd ff:ff:ff:ff:ff:ff
>         vf 0 MAC 2a:18:8f:4d:3d:d4, tx rate 700 (Mbps), max_tx_rate 700Mbps, min_tx_rate 200Mbps
>         vf 1 MAC 72:dc:ba:f9:df:fd
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Applied to net-next branch
