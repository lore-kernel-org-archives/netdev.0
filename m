From: James Chapman <jchapman@katalix.com>
Subject: Re: RFR: New e1000 driver (e1000new), was: Re: e1000: backport ich9
 support from 7.5.5 ?
Date: Sun, 08 Jul 2007 19:41:30 +0100
Message-ID: <46912FDA.4060403@katalix.com>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <468594B7.6070309@intel.com> <468E92F8.7010501@garzik.org> <468EDAC4.8070300@intel.com> <468F85AF.3010603@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:52427 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621AbXGHSli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 14:41:38 -0400
In-Reply-To: <468F85AF.3010603@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> I envisage something like this:-
> 
> e1000_core.c    - common code used by all drivers of the e1000 family.
>           Exports functions used by actual drivers. Loadable
>           as a separate module when built as a module.
> e1000_82541.c    - driver for 82541
> e1000_82542.c    - driver for 82542
> e1000_xxxxx.c    - driver for xxxxx

Please ignore the statement I made above. Having read the code and chip 
docs again, I realize I jumped to the wrong conclusions when I saw 
separate source files for each of the 7 chip variants in the new driver.

Just wanted to nip it in the bud before it causes any wasted time 
discussing it. :)

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

