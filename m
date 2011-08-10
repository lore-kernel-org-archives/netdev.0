From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4] Bridge: Always send NETDEV_CHANGEADDR up on br MAC
 change.
Date: Tue, 09 Aug 2011 21:45:01 -0700 (PDT)
Message-ID: <20110809.214501.695156031507081645.davem@davemloft.net>
References: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
	<1312578250-2944-2-git-send-email-andreiw@motorola.com>
	<20110808131230.7f4b4d99@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreiw@motorola.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1HJEpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 00:45:11 -0400
In-Reply-To: <20110808131230.7f4b4d99@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 8 Aug 2011 13:12:30 -0700

> On Fri,  5 Aug 2011 16:04:10 -0500
> Andrei Warkentin <andreiw@motorola.com> wrote:
> 
>> This ensures the neighbor entries associated with the bridge
>> dev are flushed, also invalidating the associated cached L2 headers.
>> 
>> This means we br_add_if/br_del_if ports to implement hand-over and
>> not wind up with bridge packets going out with stale MAC.
>> 
>> This means we can also change MAC of port device and also not wind
>> up with bridge packets going out with stale MAC.
>> 
>> This builds on Stephen Hemminger's patch, also handling the br_del_if
>> case and the port MAC change case.
>> 
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: Andrei Warkentin <andreiw@motorola.com>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
