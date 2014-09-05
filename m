From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] ipv6: add sysctl_mld_qrv to configure
 query robustness variable
Date: Thu, 04 Sep 2014 22:26:37 -0700 (PDT)
Message-ID: <20140904.222637.1351147235438370932.davem@davemloft.net>
References: <3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaIEF0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:26:38 -0400
In-Reply-To: <3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue,  2 Sep 2014 15:49:25 +0200

> This patch adds a new sysctl_mld_qrv knob to configure the mldv1/v2 query
> robustness variable. It specifies how many retransmit of unsolicited mld
> retransmit should happen. Admins might want to tune this on lossy links.
> 
> Also reset mld state on interface down/up, so we pick up new sysctl
> settings during interface up event.
> 
> IPv6 certification requests this knob to be available.
> 
> I didn't make this knob netns specific, as it is mostly a setting in a
> physical environment and should be per host.
> 
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
