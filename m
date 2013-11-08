From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 9/10] bonding: remvoe unwanted lock for bond
 enslave and release
Date: Fri, 08 Nov 2013 18:15:51 +0100
Message-ID: <527D1C47.4040008@redhat.com>
References: <527C4793.5060306@huawei.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:39116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757532Ab3KHRTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 12:19:18 -0500
In-Reply-To: <527C4793.5060306@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2013 03:08 AM, Ding Tianhong wrote:
> The bond_change_active_slave() and bond_select_active_slave()
> do't need bond lock anymore, so remove the unwanted bond lock
> for these two functions.
> 
> The bond_select_active_slave() will release and acquire
> curr_slave_lock, so the curr_slave_lock need to protect
> the function.
> 
> In bond enslave and bond release, the bond slave list is also
> protected by RTNL, so bond lock is no need to exist, remove
> the lock and clean the functions.
> 
> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
Small nitpick about the subject:
"remvoe" -> "remove"
