From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 2 Nov 2015 07:13:31 +0100
Message-ID: <20151102061331.GA2216@nanopsycho.orion>
References: <20150930135141.GF2098@nanopsycho.orion>
 <20151101.115116.620913426492186507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38404 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbKBGNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 01:13:34 -0500
Received: by wicll6 with SMTP id ll6so42936928wic.1
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2015 22:13:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151101.115116.620913426492186507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Nov 01, 2015 at 05:51:16PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 30 Sep 2015 15:51:41 +0200
>
>> 2) generic Netlink (genl) interface. Easy to put metadata in, including the
>> device identificator (pci address). User then can use nlmon in order to
>> be able to use wireshark to see the netlink messages.
>> 
>> Looks like 2) might be viable, well-defined, generic interface to carry
>> this info. What do you think? Does this make sense?
>
>Sorry for the late response.  I definitely prefer this netlink idea,
>particularly for the metadata aspect.
>
>Yes, the ethernet frames should "identify" the device, but I much more
>like the idea of precisely having the geographic ID of the device (PCI
>ID, whatever) available as metadata as well.

Okay. Thanks!
