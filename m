From: David Miller <davem@redhat.com>
Subject: Re: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
Date: Tue, 17 Mar 2015 15:23:24 -0400 (EDT)
Message-ID: <20150317.152324.744727347577991569.davem@redhat.com>
References: <1426608145-14139-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbbCQTXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 15:23:35 -0400
In-Reply-To: <1426608145-14139-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Tue, 17 Mar 2015 09:02:25 -0700

> Take into consideration the xmit_more flag in skb to decide if we should
> notify the host as we place packets in VMBUS.
> 
> The VMBUS API that would give us this control is already in Greg's tree, in this
> patch-set, that API is exported so it can be used in the netvsc driver. Greg has
> acked this export.
> 
> In this version of the patch-set, the patch to address the vmbus signalling
> fix is not included here; that patch will be taken through Greg's tree.
> I have also gotten rid of an unnecessary local variable in start_xmit()
> function based on feedback from Jason Wang <jasowang@redhat.com>.

This patch set does not apply to net-next at all.
