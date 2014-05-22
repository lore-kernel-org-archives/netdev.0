From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/2] net/mlx4_core: Deprecate use_prio module
 parameter
Date: Thu, 22 May 2014 15:59:28 +0300
Message-ID: <537DF4B0.3050006@mellanox.com>
References: <1400488662-5657-1-git-send-email-amirv@mellanox.com>	<1400488662-5657-2-git-send-email-amirv@mellanox.com> <20140521.154952.422112298525039373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.com>,
	<ogerlitz@mellanox.com>, <clsoto@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:49641 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754852AbaEVNAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 09:00:48 -0400
In-Reply-To: <20140521.154952.422112298525039373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/21/2014 10:49 PM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Mon, 19 May 2014 11:37:41 +0300
>
>> It was used for steering by user priority for A0 steering. A0 mode is
>> not supported anymore. Printing a message and ignoring the parameter.
>>
>> CC: Carol Soto <clsoto@linux.vnet.ibm.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>
> So you completely took away a feature that was publicly exposed and
> available to the user?
>
> Sorry this is still not acceptable, you have to bring back A0
> steering, what if someone was using it?
>
> I sense you really don't care, and that I find really disturbing.
>

My description wasn't accurate. I resubmitted the patch set with a 
better explanation about the purpose of this module param, and why we 
don't expect that anything will break for anyone because we deprecated it.

Amir
