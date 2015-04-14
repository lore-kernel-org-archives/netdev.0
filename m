From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] stmmac: rmmod oops after ifconfig on interface
Date: Tue, 14 Apr 2015 14:13:52 -0400 (EDT)
Message-ID: <20150414.141352.1998810106861142707.davem@davemloft.net>
References: <552BB695.9090508@nexus-software.ie>
	<552BC36F.3060809@nexus-software.ie>
	<CAHp75VckYS54tVjCoqLSNbgAa48h5+Vp4XGXV1qCmahxOYbEzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pure.logic@nexus-software.ie, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844AbbDNSNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:13:55 -0400
In-Reply-To: <CAHp75VckYS54tVjCoqLSNbgAa48h5+Vp4XGXV1qCmahxOYbEzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Mon, 13 Apr 2015 16:33:46 +0300

> Hmm... By some reason this didn't make mailing list.
> 
> On Mon, Apr 13, 2015 at 4:23 PM, Bryan O'Donoghue
> <pure.logic@nexus-software.ie> wrote:
>> Might be a bit of an issue getting you a 'fixes' tag - I can't bisect back
>> in time very far - very soon we stop booting.
>>
>> Would you be happy with a fixes that indicates the original checkin
>> sequenced the unregister_netdev(); and mdiobus_unreg() in the wrong order ?
> 
> I actually think David could help us in this.
> 
>> Basically the 'fixes' tag then would be 47dd7a540
>> net: add support for STMicroelectronics Ethernet controllers.
> 
> I don't know how to proceed in such cases since the patch will
> apparently not apply to that commit.

Please resubmit your original fix with an appropriate Fixes: tag.

Thank you.
