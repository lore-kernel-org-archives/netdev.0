From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 16:04:32 -0700 (PDT)
Message-ID: <20100422.160432.172292134.davem@davemloft.net>
References: <20100421.234849.51685723.davem@davemloft.net>
	<C7F60C62.2AC93%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753580Ab0DVXE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 19:04:28 -0400
In-Reply-To: <C7F60C62.2AC93%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Thu, 22 Apr 2010 14:23:30 -0700

> On 4/21/10 11:48 PM, "David Miller" <davem@davemloft.net> wrote:
> 
>> From: Scott Feldman <scofeldm@cisco.com>
>> Date: Mon, 19 Apr 2010 12:18:07 -0700
>> 
>>> +#define IOVNL_PROTO_VERSION 1
>>> +
>> 
>> Please delete this in the final version, the macro isn't even used by
>> the code.
>> 
>> We don't do protocol versioning in netlink.  Instead we get the base
>> stuff solid from the beginning, and then if something needs fixing up
>> we handle this using new attributes in a way which is both backward
>> and forward compatible.
> 
> Sounds good to me, was a cut-and-paste from dcbnl.h.  How about:

This is perfectly fine except it got whitespace damanged by your
email client and needs a proper commit message and signoff :-)
