From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] af_ieee802154: provide dummy get/setsockopt
Date: Wed, 05 Aug 2009 20:19:37 -0700 (PDT)
Message-ID: <20090805.201937.242694288.davem@davemloft.net>
References: <1249457297-8355-3-git-send-email-dbaryshkov@gmail.com>
	<20090805.121714.182898812.davem@davemloft.net>
	<20090805214139.GA6553@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbZHFDT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 23:19:29 -0400
In-Reply-To: <20090805214139.GA6553@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Thu, 6 Aug 2009 01:41:39 +0400

> On Wed, Aug 05, 2009 at 12:17:14PM -0700, David Miller wrote:
>> From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>> Date: Wed,  5 Aug 2009 11:28:16 +0400
>> 
>> > Provide dummt get/setsockopt implementations to stop these
>> > syscalls from oopsing on our sockets.
>> > 
>> > Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>> 
>> See "sock_no_getsockopt()" and "sock_no_setsockopt()" which are
>> provided specifically for this situation.
> 
> There functions are to be used in struct proto_ops and not in the
> struct proto. I'd like to use sock_common_get/setsockopt() from the
> beginning, as there will be sockopts at least for dgram protocols.

Ok, my bad.  The patch is fine.
