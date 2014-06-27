From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] powerpc: bpf: Use correct mask while accessing
 the VLAN tag
Date: Fri, 27 Jun 2014 16:14:34 -0700 (PDT)
Message-ID: <20140627.161434.502036633250565046.davem@davemloft.net>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbaF0XOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:14:35 -0400
In-Reply-To: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 25 Jun 2014 21:34:56 +0400

> To get a full tag (and not just a VID) we should access the TCI
> except the VLAN_TAG_PRESENT field (which means that 802.1q header
> is present). Also ensure that the VLAN_TAG_PRESENT stay on its place
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Applied.
