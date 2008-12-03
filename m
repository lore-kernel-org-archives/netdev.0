From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [Question] e1000: e1000_adapter->polling_netdev is useless
Date: Wed, 3 Dec 2008 01:48:32 -0800
Message-ID: <9929d2390812030148s4ee16a82ge709083387f9acff@mail.gmail.com>
References: <49353915.4060002@cn.fujitsu.com>
	 <20081202.150623.70107608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:18280 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYLCJsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 04:48:33 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1405367yxm.1
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2008 01:48:32 -0800 (PST)
In-Reply-To: <20081202.150623.70107608.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 2, 2008 at 3:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Tue, 02 Dec 2008 21:33:09 +0800
>
>> e1000_adapter->polling_netdev is not actually used after allocated.
>> So, my question is that is it useless?
>
> It's probably a leftover from before we added support for
> multiqueue NAPI.
>
> Intel folks can probably confirm.
> --
>

Yeah, Dave appears to be correct.

-- 
Cheers,
Jeff
