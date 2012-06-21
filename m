From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [RFC net-next 00/14] default maximal number of RSS queues
 in mq drivers
Date: Thu, 21 Jun 2012 08:15:36 +0300
Message-ID: <4FE2ADF8.8010508@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
 <1340225015.2576.27.camel@bwh-desktop.uk.solarflarecom.com>
 <1340225323.2576.30.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com,
	"Divy Le Ray" <divy@chelsio.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	"Jon Mason" <jdmason@kudzu.us>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	"Ron Mercer" <ron.mercer@qlogic.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Jon Mason" <mason@myri.com>,
	"Andrew Gallatin" <gallatin@myri.com>,
	"Sathya Perla" <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	"Ajit Khaparde" <ajit.khaparde@emulex.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3505 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754705Ab2FUFRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 01:17:45 -0400
In-Reply-To: <1340225323.2576.30.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2012 11:48 PM, Ben Hutchings wrote:

> Also, I would recommend encapsulating the calculation of default number
> of RSS queues in a function, rather than repeating it in every driver.
> That will make it easier to replace with something more sophisticated
> and configurable later on.
> 
> Ben.
> 

Do You also have the notion of where's the correct place to place such a
function?

Thanks,
Yuval
