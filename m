From: Debashis Dutt <debdut@gmail.com>
Subject: Re: [RFC PATCH 1/1] bna: Generic Netlink Interface to collect FW trace
Date: Thu, 28 Apr 2011 10:51:27 -0700
Message-ID: <BANLkTimOuF+HtLxsmTGVpC7ahU_NFy_L2g@mail.gmail.com>
References: <1303869117-780-1-git-send-email-rmody@brocade.com>
	<20110426185917.3d033636@nehalam>
	<BANLkTinUsJ2foWKBVb_9nVFA2V_vKb11rA@mail.gmail.com>
	<20110426.191707.71110914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, rmody@brocade.com, netdev@vger.kernel.org,
	huangj@brocade.com, amathur@brocade.com, ddutt@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33661 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab1D1Rv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 13:51:29 -0400
Received: by fxm17 with SMTP id 17so1979355fxm.19
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 10:51:28 -0700 (PDT)
In-Reply-To: <20110426.191707.71110914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 7:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Debashis Dutt <debdut@gmail.com>
> Date: Tue, 26 Apr 2011 19:16:29 -0700
>
>> However, since the generic netlink is a more generic interface, we could use
>> this infrastructure in the driver for commands which are not part of
>> other standard tools.
>
> You aren't the only device in the world that might want to provide
> a facility to fetch firmware traces.
>
> This isn't really a niche thing specific to your device at all.
>

David,

Agreed.

In that case should we use debugfs for collecting f/w trace,
but use generic netlink for other h/w specific commands?

 Thanks
 --Debashis
