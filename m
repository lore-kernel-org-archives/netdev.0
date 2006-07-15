From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 18:39:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607151837530.28012@d.namei>
References: <20060714185739.780700000@flek.zko.hp.com>
 <20060714185915.270209000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:52369 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964796AbWGOWkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 18:40:00 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060714185915.270209000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006, paul.moore@hp.com wrote:

> +int cipso_v4_cache_add(const struct sk_buff *skb,
> +		       const struct netlbl_lsm_secattr *secattr)
> +{

It seems that this cache grows without bounds, correct?

Also, how do you handle the case of a change to a cached mapping?



- James
-- 
James Morris
<jmorris@namei.org>
