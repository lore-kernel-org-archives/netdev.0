From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: Re: [PATCH] bond_alb: do not disable BH under netpoll
Date: Wed, 04 Jan 2012 00:14:39 -0800
Message-ID: <4F040A6F.2000002@oracle.com>
References: <1325643618-3051-1-git-send-email-maxim.uvarov@oracle.com> <20120103.214919.346240095248499387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:32931 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab2ADIOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 03:14:46 -0500
In-Reply-To: <20120103.214919.346240095248499387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.01.2012 18:49, David Miller wrote:
> From: Maxim Uvarov<maxim.uvarov@oracle.com>
> Date: Tue,  3 Jan 2012 18:20:18 -0800
>
>> Do not disable BH if interrupts are already disabled
>> (netpoll case).
>> Signed-off-by: Maxim Uvarov<maxim.uvarov@oracle.com>
> Barf...
>
> We should never use conditional locking like this.


How about change spin_lock_bh  to spin_lock_irqsave at this place?

Maxim.
