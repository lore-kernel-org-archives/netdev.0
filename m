From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 01 Oct 2009 13:12:34 -0700
Message-ID: <1254427954.3538.2.camel@localhost.localdomain>
References: <20090924180048.14503.9579.stgit@tikku>
	 <43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com>
	 <20090925044258.GA2722@tuxdriver.com>
	 <da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com>
	 <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com>
	 <20091001011340.GA3123@tuxdriver.com> <87fxa3qjt2.fsf@purkki.valot.fi>
	 <20091001151820.GA2895@tuxdriver.com> <873a63qe6e.fsf@purkki.valot.fi>
	 <20091001170722.GC2895@tuxdriver.com>
	 <43e72e890910011256v18b30e7ck420ce80b5d35fdcb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Kalle Valo <kalle.valo@iki.fi>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56691 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254AbZJAUNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 16:13:54 -0400
In-Reply-To: <43e72e890910011256v18b30e7ck420ce80b5d35fdcb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-01 at 13:56 -0600, Luis R. Rodriguez wrote:
> On Thu, Oct 1, 2009 at 5:07 PM, John W. Linville <linville@tuxdriver.com> wrote:
> 
> > I don't predict a huge problem if there are
> > valid extensions required for use by wireless drivers in the future.
> > But for now, I'd like to see us make use of some of the debugging
> > facilities available in the ethtool API -- hopefully the iwlwifi guys
> > are listening... ;-)
> 
> Does the same apply to wimax then? Ethtool for 802.11 and wimax? Eh.

Not really -- WiMAX is not eth-frame based, but IP based.

The WiMAX stack doesn't require any type of framing/network device
typing requirement. That is left up to the device driver writer
(although yes, emulating eth is easier).

-- 
-- Inaky


