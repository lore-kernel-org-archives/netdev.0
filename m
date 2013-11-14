From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] bonding: add ip checks when store ip target
Date: Thu, 14 Nov 2013 16:55:16 -0500 (EST)
Message-ID: <20131114.165516.863952218326737474.davem@davemloft.net>
References: <5284ADD2.2060004@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab3KNVzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:55:20 -0500
In-Reply-To: <5284ADD2.2060004@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 14 Nov 2013 19:02:42 +0800

>  	targets = bond->params.arp_targets;
> -	newtarget = in_aton(buf + 1);
> +	if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL) ||
> +			IS_IP_TARGET_UNUSABLE_ADDRESS(newtarget)) {

This is not indented correctly.

On the second line, the IS_IP_TARGET... should start at the very
first column after the openning parenthesis on the previous line.

If you are using only TAB characters to indent, rather than an
appropriate mix of TAB and SPACE characters, you are doing it
wrong.

Thanks.
