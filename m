From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6] forcedeth: call vlan_mode only if hw supports
 vlans
Date: Wed, 17 Aug 2011 23:50:44 -0700 (PDT)
Message-ID: <20110817.235044.939761208558380218.davem@davemloft.net>
References: <1313649471-31555-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mirqus@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, akpm@linux-foundation.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab1HRGu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 02:50:56 -0400
In-Reply-To: <1313649471-31555-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 18 Aug 2011 08:37:51 +0200

> If hw does not support vlans, dont call nv_vlan_mode because it has no point.
> I believe that this should fix issues on older non-vlan supportive
> chips (like Ingo has).
> 
> Reported-ty: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
