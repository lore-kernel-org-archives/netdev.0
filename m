From: "Divy Le Ray" <divy@chelsio.com>
Subject: Re: [PATCH 2.6.30] cxgb3: clear shadow BAR registers
Date: Wed, 01 Apr 2009 10:48:48 -0700
Message-ID: <op.urpyfmweduofyu@cayman.asicdesigners.com>
References: <20090401005854.15175.44595.stgit@speedy5>
 <20090331.203457.210552824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:5120 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756153AbZDARvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 13:51:46 -0400
In-Reply-To: <20090331.203457.210552824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Mar 2009 20:34:57 -0700, David Miller <davem@davemloft.net>  
wrote:

> From: Divy Le Ray <divy@chelsio.com>
> Date: Tue, 31 Mar 2009 17:58:54 -0700
>
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Ensure that internal shadow BAR registers are cleared on 32-bit  
>> platforms.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>
> Why is this a problem and why is it not possible to rely
> on these being setup to zero by either the BIOS or the PCI
> layer?
>
> At best this is a PCI quirk and not something that belongs
> in the driver.
>
> I'm not applying this.

Hi Dave,

You are right, this issue is motherboard specific and seems to have been  
fixed a loong time ago.
Sorry for the spam.

Cheers,
Divy



