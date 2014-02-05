From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix L2-GRE TCP issues
Date: Tue, 04 Feb 2014 20:34:16 -0800 (PST)
Message-ID: <20140204.203416.1197655024209227946.davem@davemloft.net>
References: <1391528583-22935-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com, ariele@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbaBEEeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:34:17 -0500
In-Reply-To: <1391528583-22935-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>
Date: Tue, 4 Feb 2014 17:43:03 +0200

> When configuring GRE tunnel using OVS, tcp stream is distributed over
> all RSS queues which may cause TCP reordering. It happens since OVS
> uses L2GRE protocol when kernel gre uses IPGRE.
> Patch defaults gre tunnel to L2GRE which allows proper RSS for L2GRE
> packets and (implicitly) disables RSS for IPGRE traffic.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
