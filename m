From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6] if_vlan.h: fix compile errors
Date: Wed, 13 Apr 2011 12:57:59 +0200
Message-ID: <20110413105758.GA2910@psychotron.orion>
References: <1302690737-14524-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155Ab1DMK6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 06:58:02 -0400
Content-Disposition: inline
In-Reply-To: <1302690737-14524-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jeff, this fix was already submitted by DaveM

Wed, Apr 13, 2011 at 12:32:17PM CEST, jeffrey.t.kirsher@intel.com wrote:
>The following commit generates compile errors becuase vlan_untag was defined
>multiple times.
>
>    commit bcc6d47903612c3861201cc3a866fb604f26b8b2
>    Author: Jiri Pirko <jpirko@redhat.com>
>    Date:   Thu Apr 7 19:48:33 2011 +0000
>
>    net: vlan: make non-hw-accel rx path similar to hw-accel
>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>---
> include/linux/if_vlan.h |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>index 998b299..546d9d3 100644
>--- a/include/linux/if_vlan.h
>+++ b/include/linux/if_vlan.h
>@@ -174,7 +174,7 @@ static inline bool vlan_do_receive(struct sk_buff **skb)
> 	return false;
> }
> 
>-inline struct sk_buff *vlan_untag(struct sk_buff *skb)
>+static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
> {
> 	return skb;
> }
>-- 
>1.7.4.2
>
