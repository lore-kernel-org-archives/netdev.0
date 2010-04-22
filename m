From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 14:23:30 -0700
Message-ID: <C7F60C62.2AC93%scofeldm@cisco.com>
References: <20100421.234849.51685723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <chrisw@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:45574 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758302Ab0DVVXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:23:34 -0400
In-Reply-To: <20100421.234849.51685723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/10 11:48 PM, "David Miller" <davem@davemloft.net> wrote:

> From: Scott Feldman <scofeldm@cisco.com>
> Date: Mon, 19 Apr 2010 12:18:07 -0700
> 
>> +#define IOVNL_PROTO_VERSION 1
>> +
> 
> Please delete this in the final version, the macro isn't even used by
> the code.
> 
> We don't do protocol versioning in netlink.  Instead we get the base
> stuff solid from the beginning, and then if something needs fixing up
> we handle this using new attributes in a way which is both backward
> and forward compatible.

Sounds good to me, was a cut-and-paste from dcbnl.h.  How about:

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index b7cdbb4..8723491 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -22,8 +22,6 @@
 
 #include <linux/types.h>
 
-#define DCB_PROTO_VERSION 1
-
 struct dcbmsg {
        __u8               dcb_family;
        __u8               cmd;

-scott

