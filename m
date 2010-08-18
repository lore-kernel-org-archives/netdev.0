From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Broadcom 5709 take long time to bring up
Date: Wed, 18 Aug 2010 23:19:32 +0100
Message-ID: <1282169972.3454.148.camel@localhost>
References: <20100818143432.GA29386@joejin-pc.cn.oracle.com>
	 <1282147735.3880.83.camel@localhost>
	 <70AE41F9-6FB7-43E3-A0C0-450E964A9B56@earthlink.net>
	 <4C6C4FE5.20509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mitchell Erblich <erblichs@earthlink.net>,
	Benjamin Li <benli@broadcom.com>, Joe Jin <joe.jin@oracle.com>,
	Michael Chan <mchan@broadcom.com>,
	"terry.liu@oracle.com" <terry.liu@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2878 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab0HRWTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 18:19:39 -0400
In-Reply-To: <4C6C4FE5.20509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-18 at 14:25 -0700, Rick Jones wrote:
> Mitchell Erblich wrote:
> > On Aug 18, 2010, at 9:08 AM, Benjamin Li wrote:
> > 
> > 
> >>Hi Joe,
> >>
> >>Just a couple of quick questions:
> >>
> >>1.  It is possible that autonegotiation could take in the orders of
> >>seconds depending on the remote partner.   
> > 
> > 
> > No. It happens in ms.
> > 
> > Mitchell Erblich
> 
> Both may be correct, depending on the context.  The IEEE specs likely mandate 
> that autonegotiation take no longer than N ms, but there may indeed be kit out 
> there that takes rather longer...

Autonegotiation per se should not take very long, but 1000BASE-T or
10GBASE-T also require the PHYs to sync clocks, detect and cancel
echoes, and so on.  I believe that that link training normally takes a
few seconds after AN is done.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

