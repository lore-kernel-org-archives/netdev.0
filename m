From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3.16]r8169:  Correct value from speed 10 on
 MII_BMCR
Date: Fri, 25 Mar 2016 23:53:25 +0100
Message-ID: <20160325225325.GA28935@electric-eye.fr.zoreil.com>
References: <1458910866-21784-1-git-send-email-asd@marian1000.go.ro>
 <20160325133113.3001B62813@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49508 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbcCYWxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:53:36 -0400
Content-Disposition: inline
In-Reply-To: <20160325133113.3001B62813@mail.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Sutter <phil@nwl.cc> :
[...]
> Your patch submissions are getting better, also good to see you're
> finally using git-send-email. A few things need to be corrected though:
> 

#define BMCR_RESV               0x003f  /* Unused...                   */
#define BMCR_SPEED1000          0x0040  /* MSB of Speed (1000)         */
#define BMCR_CTST               0x0080  /* Collision test              */
#define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
#define BMCR_ANRESTART          0x0200  /* Auto negotiation restart    */
#define BMCR_ISOLATE            0x0400  /* Isolate data paths from MII */
#define BMCR_PDOWN              0x0800  /* Enable low power state      */
#define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
#define BMCR_SPEED100           0x2000  /* Select 100Mbps              */
#define BMCR_LOOPBACK           0x4000  /* TXD loopback bits           */

BMCR_SPEED100 apart, *all* these bits are now set.

It does not make much sense.

> Also detailed instructions on how to trigger the problem you are fixing
> for would be good. In detail: Which specific hardware was used, in which
> situation did the problem occur, how did it behave in that situation and
> what was the expected behaviour?

Been there. Such requests are usually left unanswered. :o(

Btw, this stuff targets 3.16 (...) and net-next is still closed.

-- 
Ueimor
