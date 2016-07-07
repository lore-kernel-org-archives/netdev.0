From: Masashi Honma <masashi.honma@gmail.com>
Subject: Re: [RFC 0/7] netlink: Add allocation flag to netlink_unicast()
Date: Thu, 7 Jul 2016 09:35:45 +0900
Message-ID: <577DA3E1.6020103@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-audit@redhat.com, cluster-devel@redhat.com,
	davem@davemloft.net, johannes@sipsolutions.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, paul@paul-moore.com, eparis@redhat.com,
	zbr@ioremap.net, pshelar@nicira.com, bsingharora@gmail.com
To: ccaulfie@redhat.com, teigland@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33439 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504AbcGGAfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 20:35:53 -0400
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the fs/dlm/netlink.c#dlm_timeout_warn(),
prepare_data allocates buffer with GFP_NOFS
and send_data() sends the buffer.

But send_data() uses GFP_KERNEL or GFP_ATOMIC inside it.
Should it be replaced by GFP_NOFS ?

Masashi Honma
