From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] neighbour : fix ndm_type type error issue
Date: Mon, 28 Jul 2014 17:52:33 -0700 (PDT)
Message-ID: <20140728.175233.1660108980399375435.davem@davemloft.net>
References: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	therbert@google.com, netdev@vger.kernel.org, ffusco@redhat.com,
	vfalico@redhat.com, duanj.fnst@cn.fujitsu.com,
	hannes@stressinduktion.org, jiri@resnulli.us, dlstevens@us.ibm.com,
	ogerlitz@mellanox.com, dborkman@redhat.com,
	linux-kernel@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbaG2Awf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 20:52:35 -0400
In-Reply-To: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Sat, 26 Jul 2014 00:38:59 +0800

> ndm_type means L3 address type, in neighbour proxy and vxlan, it's RTN_UNICAST.
> NDA_DST is for netlink TLV type, hence it's not right value in this context.
> 
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

This change is definitely correct, applied, thanks.
