From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUG-FIX] udp_diag: implement idiag_get_info for
 udp/udplite to get queue information
Date: Wed, 25 Apr 2012 20:46:27 -0400 (EDT)
Message-ID: <20120425.204627.784347732080272287.davem@davemloft.net>
References: <4F977A6D.1050508@gmail.com>
	<4F97EDEF.60202@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei88@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org, davidshan@tencent.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932716Ab2DZAsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:48:01 -0400
In-Reply-To: <4F97EDEF.60202@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 25 Apr 2012 16:28:31 +0400

> On 04/25/2012 08:15 AM, Shan Wei wrote:
>> From: Shan Wei <davidshan@tencent.com>
>> 
>> When we use netlink to monitor queue information for udp socket,
>> idiag_rqueue and idiag_wqueue of inet_diag_msg are returned with 0.
>> 
>> Keep consistent with netstat, just return back allocated rmem/wmem size.
>> 
>> Signed-off-by: Shan Wei <davidshan@tencent.com>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied, thanks.
