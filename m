From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 24 Nov 2015 10:43:17 -0800
Message-ID: <CALx6S35+A4ematcdnHwBa-EBWXwBo19gaDp5zhNKG_7xxfU=Nw@mail.gmail.com>
References: <20151123171103.00007699@unknown>
	<CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
	<1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
	<20151124.133754.654421175431044735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33815 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbbKXSnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:43:18 -0500
Received: by ioir85 with SMTP id r85so29757564ioi.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:43:17 -0800 (PST)
In-Reply-To: <20151124.133754.654421175431044735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 10:37 AM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 24 Nov 2015 18:43:35 +0100
>
>> On Tue, Nov 24, 2015, at 18:32, Tom Herbert wrote:
>>> As you said this in only feedback and nobody is forcing anyone to do
>>> anything. But encouraging HW vendors to provide generic mechanisms so
>>> that your users can use whatever protocol they want is the exact
>>> _opposite_ of punishing users, this is very much a pro-user direction.
>>
>> Some users will suffer worse performance in case we don't correctly set
>> ip_summed for a specific protocol before we do the copy operations from
>> user space into skbs but if they are always done in the driver.
>
> Your concern presumes that looking backwards is as important as looking
> forward.
>
> We want to simplify things _and_ move away from protocol specific
> csums, and if some old crufty hardware based systems pay some performance
> cost for this I say so be it.
>
> So this is not a valid argument against Tom's changes in my mind.
>
And for that matter these arguments have nothing to do with these UDP
encapsulation patches at all, they seem to be directed to the patches
to eliminate NETIF_F_IP{V6}_CSUM so please post on that thread.
