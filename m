From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 5/8] stmmac: get/set coalesce parameters via ethtool
Date: Tue, 11 Sep 2012 08:58:02 +0200
Message-ID: <504EE0FA.8050907@st.com>
References: <1347262689-21251-1-git-send-email-peppe.cavallaro@st.com>  <1347262689-21251-6-git-send-email-peppe.cavallaro@st.com> <1347295510.2823.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:60325 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753011Ab2IKG6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 02:58:09 -0400
In-Reply-To: <1347295510.2823.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben

On 9/10/2012 6:45 PM, Ben Hutchings wrote:
> You should also check that the settings you don't support
> (rx_max_coalesced_frames, use_adaptive_rx_coalesce,
> use_adaptive_tx_coalesce, *_irq) are equal to 0.  (This isn't done
> consistently in all drivers - but I believe best practice is to reject
> rather than quietly ignoring settings you don't support.)

Agreed. I've added this check in ethtool and now, for example, I get the
following on un-supported setting

$ ethtool -C eth0 tx-usecs-irq 50
Cannot set device ring parameters: Operation not supported
$ ethtool -C eth0 tx-usecs-irq 0
tx-usecs-irq unmodified, ignoring
no ring parameters changed, aborting

> 
> I don't have time to review the other changes properly, but at a quick
> look they seem to be OK.

Thanks a lot

peppe

> 
> Ben.
> 
