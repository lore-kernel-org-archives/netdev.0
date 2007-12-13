From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 11:35:07 -0800
Message-ID: <4761896B.7070801@linux-foundation.org>
References: <20071213.061938.86541759.davem@davemloft.net>	<20071213102233.3727e9a0@freepuppy.rosehill>	<476181C1.3060204@myri.com> <20071213.110928.26060224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, joonwpark81@gmail.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43236 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754915AbXLMTfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 14:35:38 -0500
In-Reply-To: <20071213.110928.26060224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Thu, 13 Dec 2007 14:02:25 -0500
>
>   
>> Or perhaps we should just leave things as is.
>>     
>
> We should probably add a "disabling" state bit to the
> napi struct flags, this will be set by napi_disable()
> before it loops trying to set the sched bit.
>
> net_rx_action() can then check this.
>   
How about allowing a return value of -1 from napi_poll and letting device
check itself.
