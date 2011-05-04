From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: Support to take FW dump
Date: Tue, 3 May 2011 22:22:47 -0700
Message-ID: <C683AC52-87BE-41F9-BA3A-58846A640F9D@qlogic.com>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1304378957-24123-2-git-send-email-anirban.chakraborty@qlogic.com>
 <1304466797.2873.38.camel@bwh-desktop>
 <2941C562-0D47-40DF-B2C0-6292381097AE@qlogic.com>
 <1304471194.3203.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:48702 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296Ab1EDFYr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 01:24:47 -0400
In-Reply-To: <1304471194.3203.5.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 3, 2011, at 6:06 PM, Ben Hutchings wrote:

> <snip>
> 
> I understand that the userland application will need to get the size
> that way.  I'm saying that this code in the kernel should also get the
> size from the driver, so that a malicious application cannot make the
> kernel allocate an excessively large buffer.
Makes sense. Will do so.

> 
> Also, you'll need to submit your implementation along with this, as
> David won't accept an extension to the API without a driver that
> implements it.
I have implemented it in qlcnic driver. Will submit it along with the v2 patches.
Thanks.

-Anirban
