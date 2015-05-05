From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 05/10] be2net: don't enable PAUSE by default
Date: Tue, 5 May 2015 05:35:30 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C74D1075C@CMEXMB1.ad.emulex.com>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
	<1430722042-26449-6-git-send-email-sathya.perla@emulex.com>
 <20150504.115957.2215135038852456749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:2554 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030269AbbEEFgE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 01:36:04 -0400
In-Reply-To: <20150504.115957.2215135038852456749.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Sathya Perla <sathya.perla@emulex.com>
> Date: Mon,  4 May 2015 02:47:17 -0400
> 
> > From: Kalesh AP <kalesh.purayil@emulex.com>
> >
> > The driver so far, on load, always tried to enable RX/TX general pause.
> > This setting always fails on certain profiles (like FCoE) where PFC is
> > needed. Such failures cannot be effectively communicated to the stack or
> > user. To fix this unpredictability in state, this patch changes the driver
> > behavior by not configuring pause at load time.
> > The user can configure it via ethtool and if the setting is disallowed,
> > an appropriate error is returned.
...
> 
> Not enabling pause by default is going to be _STRONGLY_ not expected
> by the user and will cause unwanted packet drops in high traffic
> environments.
> 
> It's not the user's fault that your stuff is architected in such a way
> such that handling this properly isn't easy.

Ok, I'll follow up with our FW team about this and in the meantime
drop this patch from this patch-set. Thanks!

-Sathya
