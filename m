From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: Remove BUGs on paged skb data
 which crosses a page boundary
Date: Mon, 1 Dec 2014 13:27:32 +0000
Message-ID: <547C6CC4.9070605@citrix.com>
References: <1416968904-70874-1-git-send-email-seth.forshee@canonical.com> <20141126.122812.223757363894961994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <zoltan.kiss@linaro.org>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<stefan.bader@canonical.com>, <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>, <boris.ostrovsky@oracle.com>
To: David Miller <davem@davemloft.net>, <seth.forshee@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39288 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbaLAN1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 08:27:51 -0500
In-Reply-To: <20141126.122812.223757363894961994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/11/14 17:28, David Miller wrote:
> From: Seth Forshee <seth.forshee@canonical.com>
> Date: Tue, 25 Nov 2014 20:28:24 -0600
> 
>> These BUGs can be erroneously triggered by frags which refer to
>> tail pages within a compound page. The data in these pages may
>> overrun the hardware page while still being contained within the
>> compound page, but since compound_order() evaluates to 0 for tail
>> pages the assertion fails. The code already iterates through
>> subsequent pages correctly in this scenario, so the BUGs are
>> unnecessary and can be removed.
>>
>> Fixes: f36c374782e4 ("xen/netfront: handle compound page fragments on transmit")
>> Cc: <stable@vger.kernel.org> # 3.7+
>> Signed-off-by: Seth Forshee <seth.forshee@canonical.com>
> 
> Can I get some Xen developer reviews?

Sorry for the delay, I've been on holiday.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David
