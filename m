From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Wed, 15 Sep 2010 08:47:51 +0200
Message-ID: <4C906C17.6020205@free.fr>
References: <20100824115056.GA235835@jupiter.n2.diac24.net> <20100913114315.GA859019@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:58351 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab0IOGsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 02:48:05 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.1/8.13.1) with ESMTP id o8F6m2VL017095
	for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 06:48:02 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8F6m2EK3870870
	for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 08:48:02 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o8F6m1rG003418
	for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 08:48:01 +0200
In-Reply-To: <20100913114315.GA859019@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2010 01:43 PM, David Lamparter wrote:
> previously, if a vlan master device was moved from one network namespace
> to another, all 802.1q and macvlan slaves were deleted.
>
> we can use dev->reg_state to figure out whether dev_change_net_namespace
> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
> reg_state is not NETREG_UNREGISTERING.
>
> Signed-off-by: David Lamparter<equinox@diac24.net>
>    
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
