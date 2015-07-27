From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH v1 net-next 1/1] net: fec: add stop mode request on/off
 implemention
Date: Mon, 27 Jul 2015 01:27:40 +0000
Message-ID: <BN3PR0301MB1219403403FAE09C1B36E1A5F58E0@BN3PR0301MB1219.namprd03.prod.outlook.com>
References: <1437560023-9271-1-git-send-email-b38611@freescale.com>
 <20150726.162638.1540098306351231379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Li Frank <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0139.outbound.protection.outlook.com ([157.56.110.139]:53583
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751431AbbG0B7n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 21:59:43 -0400
In-Reply-To: <20150726.162638.1540098306351231379.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Monday, July 27, 2015 7:27 AM
> To: Duan Fugang-B38611
> Cc: netdev@vger.kernel.org; Li Frank-B20596; stephen@networkplumber.org
> Subject: Re: [PATCH v1 net-next 1/1] net: fec: add stop mode request
> on/off implemention
> 
> From: Fugang Duan <b38611@freescale.com>
> Date: Wed, 22 Jul 2015 18:13:43 +0800
> 
> > The current driver depends on platform data to implement stop mode
> > request on/off that call api pdata->sleep_mode_enable().
> >
> > To reduce arch platform redundancy code, since the function only set
> > SOC GPR register bit to request stop mode of/off, so we can move the
> > function into driver. And the specifix GPR register offset and MASK
> > bit can be transferred from DTS.
> >
> > Signed-off-by: Fugang Duan <B38611@freescale.com>
> 
> Doesn't this break stop mode on those devices until the DTS is updated?
> 
> That's really unfortunate, because you're leaving all of the platform
> data and implementation there, yet it's going to be unused.
> 
> I really think you need to keep the code using the platform data bits
> around until all the DTSs are updated.
> 
> No matter what you tell me about how DTSs are updated (don't even mention
> the details, I do not care) you simply cannot keep the platform data code
> around and not use it.  It is completely nonsensible to have code that
> would properly function and properly support a feature for the device in
> the kernel, yet not use it.
> 
> Period.

Thanks for your comments.

Firstly, I will send some board dts patches (and test).
Secondly, the net/next tree have no platform data for stop mode because others suggest us to use dts not platform data, and there have no any boards support stop mode in net/next, so this doesn't break any boards in net/next.

Regards,
Andy
