From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next 00/14] default maximal number of RSS queues in mq
 drivers
Date: Wed, 20 Jun 2012 21:48:43 +0100
Message-ID: <1340225323.2576.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
	 <1340225015.2576.27.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eilong@broadcom.com>, Divy Le Ray <divy@chelsio.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jon Mason <jdmason@kudzu.us>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jon Mason <mason@myri.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39113 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752394Ab2FTUss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 16:48:48 -0400
In-Reply-To: <1340225015.2576.27.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, I would recommend encapsulating the calculation of default number
of RSS queues in a function, rather than repeating it in every driver.
That will make it easier to replace with something more sophisticated
and configurable later on.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
