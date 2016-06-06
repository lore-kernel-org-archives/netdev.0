From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: vrf: Add support for local traffic
 to local addresses
Date: Mon, 06 Jun 2016 15:12:28 -0700 (PDT)
Message-ID: <20160606.151228.325662111382577833.davem@davemloft.net>
References: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbcFFWMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 18:12:32 -0400
In-Reply-To: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  2 Jun 2016 13:15:09 -0700

> Add support for locally originated traffic to VRF-local addresses,
> be it addresses on enslaved devices or addresses on the VRF device:
 ...

Series applied, but I've been wondering what happens to hw offloads
when these VRF devices sit in the middle.

Does TSO et al. still occur properly?
