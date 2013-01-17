From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V6 06/14] bridge: Add netlink interface to
 configure vlans on bridge ports
Date: Thu, 17 Jan 2013 00:52:43 -0500 (EST)
Message-ID: <20130117.005243.778308906619242836.davem@davemloft.net>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
	<1358360289-23249-7-git-send-email-vyasevic@redhat.com>
	<kd806c$ptv$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab3AQFws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 00:52:48 -0500
In-Reply-To: <kd806c$ptv$2@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 17 Jan 2013 04:54:37 +0000 (UTC)

> On Wed, 16 Jan 2013 at 18:18 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
>> +
>> +struct bridge_vlan_info {
>> +	u16 flags;
>> +	u16 vid;
>> +};
> 
> I think you have to use __u16 in UAPI headers.

That's right.
