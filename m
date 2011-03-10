From: roprabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH] if_link: Add PORT_REQUEST_MAX
Date: Wed, 09 Mar 2011 18:16:15 -0800
Message-ID: <C99D746F.218CD%roprabhu@cisco.com>
References: <20110309.124916.183062823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:32709 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab1CJCQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 21:16:17 -0500
In-Reply-To: <20110309.124916.183062823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 3/9/11 12:49 PM, "David Miller" <davem@davemloft.net> wrote:

> From: Roopa Prabhu <roprabhu@cisco.com>
> Date: Wed, 09 Mar 2011 12:34:31 -0800
> 
>> From: Roopa Prabhu <roprabhu@cisco.com>
>> 
>> This patch adds __PORT_REQUEST_MAX to port request enumeration. And defines
>> PORT_REQUEST_MAX.
>> 
>> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
>> Signed-off-by: David Wang <dwang2@cisco.com>
>> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> 
> Why?
> 
> If some new request types get added, this max value will increase and
> we don't want that to happen for things exposed to userspace.
> 
> Userspace should really not depend upon how many requests there are.

O ok. Did not know the reason why its was not there. Point taken. Pls
ignore. Thanks. 


