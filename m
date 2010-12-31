From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] CAN: Use inode instead of kernel address for /proc
 file
Date: Fri, 31 Dec 2010 11:13:04 -0800 (PST)
Message-ID: <20101231.111304.246528861.davem@davemloft.net>
References: <1293382493.9764.54.camel@Dan>
	<4D189707.5000708@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, urs.thuermann@volkswagen.de,
	netdev@vger.kernel.org, security@kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754072Ab0LaTMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 14:12:33 -0500
In-Reply-To: <4D189707.5000708@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Mon, 27 Dec 2010 14:39:19 +0100

> On 26.12.2010 17:54, Dan Rosenberg wrote:
>> Since the socket address is just being used as a unique identifier, its
>> inode number is an alternative that does not leak potentially sensitive
>> information.
>> 
>> CC-ing stable because MITRE has assigned CVE-2010-4565 to the issue.
>> 
>> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
>> Cc: stable <stable@kernel.org>
> 
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks.
