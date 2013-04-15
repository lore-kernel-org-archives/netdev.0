From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: don't bypass encapsulation for multi-
 and broadcasts
Date: Mon, 15 Apr 2013 14:06:53 -0400 (EDT)
Message-ID: <20130415.140653.1397056486872667124.davem@davemloft.net>
References: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
	<kkhbiq$5bu$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037Ab3DOSGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:06:55 -0400
In-Reply-To: <kkhbiq$5bu$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 15 Apr 2013 16:58:02 +0000 (UTC)

> On Sun, 14 Apr 2013 at 09:21 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>> The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
>> and therefore will be sent out bypassing encapsulation. This breaks
>> delivery of packets sent to the vxlan multicast group.
>> Disabling encapsulation bypass for multicasts and broadcasts fixes the
>> issue.
>>
>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> 
> This fixes the regression I reported.
> 
> Tested-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
