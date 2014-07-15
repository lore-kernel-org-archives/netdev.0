From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] bonding: enhance L2 hash helper with packet type
Date: Tue, 15 Jul 2014 10:05:36 +0200
Message-ID: <1405411536.10255.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405410083-26489-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: Xie Jianhua <Jianhua.Xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:53909 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757702AbaGOIFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 04:05:41 -0400
Received: by mail-we0-f179.google.com with SMTP id u57so2987795wes.38
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 01:05:40 -0700 (PDT)
In-Reply-To: <1405410083-26489-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 15:41 +0800, Xie Jianhua wrote:
> From: Jianhua Xie <jianhua.xie@freescale.com>
> 
> Current L2 hash helper calculates destination eth addr and
> source ether addr as L2 hash factors. This patch is adding
> packet type ID field into hash factors, which can help to
> distribute different types of packets like IPv4/IPv6 packets
> to different slave devices while only BOND_XMIT_POLICY_LAYER2
> is applied.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> CC: Pan Jiafei <Jiafei.Pan@freescale.com>
> 
> Suggested-by: David S. Miller <davem@davemloft.net>

I do not think this patch was suggested by David.

He suggested to use skb_header_pointer() which is an implementation
detail.

Anyway, patch looks fine, even if bond_eth_hash() is no longer a leaf
function.

Acked-by: Eric Dumazet <edumazet@google.com>
