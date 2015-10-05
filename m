From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 22:40:56 +0200
Message-ID: <20151005204056.GA3528@nanopsycho.orion>
References: <20150930135141.GF2098@nanopsycho.orion>
 <20151005183233.GD4890@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, eladr@mellanox.com,
	idosch@mellanox.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34209 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbJEUlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 16:41:01 -0400
Received: by wicfx3 with SMTP id fx3so137780197wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 13:40:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151005183233.GD4890@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 08:32:33PM CEST, marcelo.leitner@gmail.com wrote:
>On Wed, Sep 30, 2015 at 03:51:41PM +0200, Jiri Pirko wrote:
>> Hi Dave/all.
>> 
>> There is quite common for drivers to speak with HW using "packet-like"
>> messages. In our case, we put message into skb and push that out as
>> an ordinary packet. HW then sends us reply in a packet, similar to other
>> rx-ed packets.
>
>Better sure than sorry so I'll ask. It's not possible for an application
>to inject such skbs somehow, right?  Like, a guest, tied to a bridge,
>tied to a port which ends up understanding these skbs.

No, it's purely for monitoring of communication with HW.


>
>...
>> 2) generic Netlink (genl) interface. Easy to put metadata in, including the
>> device identificator (pci address). User then can use nlmon in order to
>> be able to use wireshark to see the netlink messages.
>> 
>> Looks like 2) might be viable, well-defined, generic interface to carry
>> this info. What do you think? Does this make sense?
>
>2 seems very interesting, fwiw
>
>  Marcelo
