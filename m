From: Maxim Osipov <maxim.osipov@gmail.com>
Subject: Re: [PATCH 2/5] net: add IEEE 802.15.4 partial implementation
Date: Thu, 28 May 2009 10:35:20 +0400
Message-ID: <6097c490905272335t55d96240j904c6f72438bd7fd@mail.gmail.com>
References: <20090526112157.GA19976@doriath.ww600.siemens.net>
	 <1243336988-20109-1-git-send-email-dbaryshkov@gmail.com>
	 <1243336988-20109-2-git-send-email-dbaryshkov@gmail.com>
	 <1243480131.16597.174.camel@deadeye>
Reply-To: maxim@mox.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:33898 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761597AbZE1GfV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 02:35:21 -0400
In-Reply-To: <1243480131.16597.174.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [...]
>> --- /dev/null
>> +++ b/include/net/ieee802154/nl.h
> [...]
>> +/* commands */
>> +/* REQ should be responded with CONF
>> + * and INDIC with RESP
>> + */
>> +enum {
>> + =A0 =A0 __IEEE802154_COMMAND_INVALID,
>> +
>> + =A0 =A0 IEEE802154_ASSOCIATE_REQ,
>> + =A0 =A0 IEEE802154_ASSOCIATE_CONF,
>> + =A0 =A0 IEEE802154_DISASSOCIATE_REQ,
>> + =A0 =A0 IEEE802154_DISASSOCIATE_CONF,
>> + =A0 =A0 IEEE802154_GET_REQ,
>> + =A0 =A0 IEEE802154_GET_CONF,
>> +/* =A0 IEEE802154_GTS_REQ, */
>> +/* =A0 IEEE802154_GTS_CONF, */
>
> Why are some of these commented out? =A0Since they're apparently expo=
sed
> to user-space you can't insert them later.
>

We are working to define a next version of netlink API for the stack
right now. But taking into account, that iz tool & upper layers of
stack will be the only users of this API at least for next year, and
IEEE802.15.4 spec is evolving, it is probably not necessary to come up
with a very final version.

Kind regards,
Maxim
