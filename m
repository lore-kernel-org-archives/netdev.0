From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sysfs: ethtool_ops can be NULL
Date: Wed, 28 Oct 2009 04:02:32 -0700 (PDT)
Message-ID: <20091028.040232.174448648.davem@davemloft.net>
References: <4AE586B5.4030308@gmail.com>
	<20091026134033.GD1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752621AbZJ1LCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 07:02:11 -0400
In-Reply-To: <20091026134033.GD1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Mon, 26 Oct 2009 09:40:33 -0400

> On Mon, Oct 26, 2009 at 12:23:33PM +0100, Eric Dumazet wrote:
>> commit d519e17e2d01a0ee9abe083019532061b4438065
>> (net: export device speed and duplex via sysfs)
>> made the wrong assumption that netdev->ethtool_ops was always set.
>> 
>> This makes possible to crash kernel and let rtnl in locked state.
>> 
>> modprobe dummy
>> ip link set dummy0 up
>> (udev runs and crash)
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> Nice catch, Eric.
> 
> Acked-by: Andy Gospodarek <andy@greyhouse.net>

Applied.
