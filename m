From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Thu, 16 Jan 2014 14:04:52 +0800
Message-ID: <52D77684.20808@oracle.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com> <20140114.152825.2110618560908841742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23344 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbaAPGFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 01:05:08 -0500
In-Reply-To: <20140114.152825.2110618560908841742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/1/15 7:28, David Miller wrote:
> From: Annie Li <Annie.li@oracle.com>
> Date: Fri, 10 Jan 2014 06:48:38 +0800
>
>> Current netfront only grants pages for grant copy, not for grant transfer, so
>> remove corresponding transfer code and add receiving copy code in
>> xennet_release_rx_bufs.
>>
>> Signed-off-by: Annie Li <Annie.li@oracle.com>
> If a Xen networking driver would review this I'd appreciate it.
>

I will re-post a new patch with improved comments. This patch mainly 
fixes leaking grant issue in netfront, and improvement on 
gnttab_end_foreign_access_ref and gnttab_end_foreign_access can be 
implemented in a separate patch.

Thanks
Annie
