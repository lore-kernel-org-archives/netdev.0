From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] minor tail loss probe improvements
Date: Thu, 13 Aug 2015 16:52:36 -0700 (PDT)
Message-ID: <20150813.165236.1796365392095140180.davem@davemloft.net>
References: <1439403499-24774-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbbHMXwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 19:52:36 -0400
In-Reply-To: <1439403499-24774-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 12 Aug 2015 11:18:17 -0700

> This patch series enhance the tail loss probe (TLP) on some error
> conditions. When TLP fails to send a probe, it will no longer
> extend the RTO. When it fails to send a new packet because of
> receiver window limit, it'll try to retransmit the last packet.

Series applied, thanks.
