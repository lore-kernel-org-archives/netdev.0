From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fire NETDEV_RELEASE event only on 0 slaves
Date: Thu, 07 Mar 2013 16:15:56 -0500 (EST)
Message-ID: <20130307.161556.554850746841856752.davem@davemloft.net>
References: <1362589832-9526-1-git-send-email-vfalico@redhat.com>
	<20130307033819.GA3513@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932840Ab3CGVP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:15:58 -0500
In-Reply-To: <20130307033819.GA3513@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 6 Mar 2013 22:38:19 -0500

> On Wed, Mar 06, 2013 at 06:10:32PM +0100, Veaceslav Falico wrote:
>> Currently, if we set up netconsole over bonding and release a slave,
>> netconsole will stop logging on the whole bonding device. Change the
>> behavior to stop the netconsole only when the last slave is released.
>> 
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks everyone.
