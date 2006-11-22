From: Patrick McHardy <kaber@trash.net>
Subject: Re: [netfilter-core] [PATCH 2.6.19-rc6] netfilter: fix panic on	ip_conntrack_h323
 with CONFIG_IP_NF_CT_ACCT
Date: Wed, 22 Nov 2006 06:51:23 +0100
Message-ID: <4563E55B.4070503@trash.net>
References: <20061120193931.GA9913@void.cube.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756902AbWKVFv2@vger.kernel.org>
To: Faidon Liambotis <paravoid@debian.org>
In-Reply-To: <20061120193931.GA9913@void.cube.gr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Faidon Liambotis wrote:
> H.323 connection tracking code calls ip_ct_refresh_acct() when
> processing RCFs and URQs but passes NULL as the skb.
> When CONFIG_IP_NF_CT_ACCT is enabled, the connection tracking core tries
> to derefence the skb, which results in an obvious panic.
> ago.
> 
> The patch uses ip_ct_refresh() instead of ip_ct_refresh_acct() to avoid
> double accounting (suggested by Patrick McHardy).


Thanks, I already fixed up your first patch and sent it
upstream/to -stable after loosing hope to hear back from
you :)
