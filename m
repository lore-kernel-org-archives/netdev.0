From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 3/5] bonding: add rtnl lock for bonding_store_xmit_hash
Date: Thu, 29 Aug 2013 16:25:42 +0200
Message-ID: <521F59E6.9050804@redhat.com>
References: <521D7ABE.5080700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753785Ab3H2O3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 10:29:54 -0400
In-Reply-To: <521D7ABE.5080700@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2013 06:21 AM, Ding Tianhong wrote:
> The bonding_store_xmit_hash() call bond_set_mode_ops() to set bond xmit_policy,
> the xmit_policy is used in xmit path for xor mode, so any changes may occur
> problem without protection, add rtnl lock is fit here.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
I don't think we need any locking there, nothing bad can happen.
