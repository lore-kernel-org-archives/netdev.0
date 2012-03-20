From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: Improve rds_sendmsg printk
Date: Tue, 20 Mar 2012 09:50:47 -0500
Message-ID: <4F689947.30405@oracle.com>
References: <20120319224008.GA23036@redhat.com> <20120319.184335.1229962428916453634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:31265 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760489Ab2CTOuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 10:50:55 -0400
In-Reply-To: <20120319.184335.1229962428916453634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/19/2012 5:43 PM, David Miller wrote:
> From: Dave Jones<davej@redhat.com>
> Date: Mon, 19 Mar 2012 18:40:09 -0400
>
>> - Given this can be called by any user, prevent them from flooding
>>    the logs by using printk_ratelimited
>> - Also add a rds: prefix, so it's clear where the message is coming from.
>>
>> Signed-off-by: Dave Jones<davej@redhat.com>
> I think it should be removed entirely, no socket layer outputs
> a message for this error and neither should rds.
Agree, the message could be removed entirely.

Venkat
