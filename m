From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 0/2] fec: move ColdFire setup code out of FEC driver
Date: Thu, 19 Feb 2009 07:53:49 +1000
Message-ID: <499C836D.6060202@snapgear.com>
References: <200902170053.n1H0r1WP002062@localhost.localdomain> <20090218164257.GI2089@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gerg@uclinux.org, netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:48653 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752871AbZBRVxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 16:53:52 -0500
In-Reply-To: <20090218164257.GI2089@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sacha,

Sascha Hauer wrote:
> On Tue, Feb 17, 2009 at 10:53:01AM +1000, Greg Ungerer wrote:
>> Hi Sascha,
>>
>> The following 2 patches move the ColdFire specific FEC setup code
>> into the ColdFire CPU platform setup code.
> 
> Looks good to me, though I can't apply them. To which tree should
> they apply?

They would go on top of your last FEC patch sets.
(At least that is what I used as the base).


>> There is still a little remaining legacy code that needs taking
>> care of in fec.c. The flash reading MAC setup code and the MII
>> link interrupts of the 5272 are still in there.
> 
> maybe the board setup code could copy the MAC Address from the
> flash directly to the device. The driver will pick it up from
> there.

Yes, that could work.

Thanks
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
