From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 17:11:51 +0200
Message-ID: <4666CEB7.6030804@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com> <1181082517.4062.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55911 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbXFFPMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 11:12:19 -0400
In-Reply-To: <1181082517.4062.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> There will be no issue if a) multiple APIs would be allowed for driver
> multi-rings[1] and b) you didnt touch the qdiscs.
>  
> Given that #a is not a sensible thing to do since there can only be one
> API and for #b you are not compromising, what do you want me to do?


I haven't followed the entire discussion, but I still don't see a
alternative to touching the qdisc layer - multiple hardware queues
need multiple queue states if you want to avoid a busy hardware
queue stopping the qdisc entirely and thereby preventing the qdisc
to continue feeding packets to other active HW queues. And to make
use of the multiple queue states you need multiple queues.

I would love to see your alternative patches.
