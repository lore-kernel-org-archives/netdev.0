From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/8] bnx2x: Minor link related fixes
Date: Thu, 02 Sep 2010 12:13:10 +0100
Message-ID: <1283425990.2272.1.camel@achroite.uk.solarflarecom.com>
References: <1283370674.4403.131.camel@lb-tlvb-yanivr.il.broadcom.com>
	 <20100901.104524.216750458.davem@davemloft.net>
	 <1283366622.5874.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.covadwireless.com ([216.237.6.30]:55812 "EHLO
	smtp.covadwireless.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909Ab0IBLXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 07:23:40 -0400
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33])
	by smtp.covadwireless.com (Spam & Virus Firewall) with ESMTP id 9A7444AC3F7
	for <netdev@vger.kernel.org>; Thu,  2 Sep 2010 04:13:13 -0700 (PDT)
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33]) by smtp.covadwireless.com with ESMTP id socVp7JvotV6Yf4w for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 04:13:13 -0700 (PDT)
Received: from unknown (HELO exchange.solarflare.com) ([216.237.3.220])
          (envelope-sender <bhutchings@solarflare.com>)
          by mail.nextweb.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 2 Sep 2010 11:13:13 -0000
In-Reply-To: <1283366622.5874.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-01 at 21:43 +0300, Eilon Greenstein wrote:
> On Wed, 2010-09-01 at 10:45 -0700, David Miller wrote:
> > Can you explain why 10mbit/100mbit links have to use forced link mode
> > and do not use autonegotiation by default?  I could understand for
> > 10mbit but 100mbit too?
> > 
> Our understanding of the requirements is that if the user selects force
> speed of 1G or higher, it is recommended to use autonegotiation with
> only that speed advertized.
[...]

This is correct. AN is absolutely required in order to establish the
clock master for 1000BASE-T and 10GBASE-T.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



