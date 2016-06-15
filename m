From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] ovs: fix rtnl notifications on interface
 deletion
Date: Tue, 14 Jun 2016 22:22:03 -0700 (PDT)
Message-ID: <20160614.222203.1524203439144421077.davem@davemloft.net>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
	<1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAOrHB_DkcsW4_eEO_TQzJEVG-=EEajLwcPtddSqK-SCUMFyYww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	jesse@kernel.org, linville@tuxdriver.com
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbcFOFWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 01:22:07 -0400
In-Reply-To: <CAOrHB_DkcsW4_eEO_TQzJEVG-=EEajLwcPtddSqK-SCUMFyYww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pravin shelar <pshelar@ovn.org>
Date: Mon, 13 Jun 2016 12:39:16 -0700

> On Mon, Jun 13, 2016 at 1:31 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>>
>> There was no rtnl notifications for interfaces (gre, vxlan, geneve) created
>> by ovs. This problem is fixed by adjusting the creation path.
>>
>> v1 -> v2:
>>  - add patch #1 and #4
>>  - rework error handling in patch #2
>>
>>  drivers/net/geneve.c | 14 ++++++++++---
>>  drivers/net/vxlan.c  | 58 ++++++++++++++++++++++++++++++----------------------
>>  net/ipv4/ip_gre.c    | 14 ++++++++++---
>>  3 files changed, 56 insertions(+), 30 deletions(-)
>>
> 
> All patches looks good to me.
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Series applied, thanks.
