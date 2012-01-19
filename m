From: Dave Jones <davej@redhat.com>
Subject: Re: iwlwifi worse than ever in current git.
Date: Thu, 19 Jan 2012 13:04:34 -0500
Message-ID: <20120119180433.GA32306@redhat.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
 <20120111014243.GA22066@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
 <20120111195055.GA5140@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3064AF5@HASMSX103.ger.corp.intel.com>
 <CANUX_P3UHz-Pr_M1H5pAbmKDY70es7nxkWSDGXG6-hvrPAMCJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	Linux Wireless <linux-wireless@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932532Ab2ASSEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 13:04:39 -0500
Content-Disposition: inline
In-Reply-To: <CANUX_P3UHz-Pr_M1H5pAbmKDY70es7nxkWSDGXG6-hvrPAMCJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 08:47:28AM +0200, Emmanuel Grumbach wrote:
 > >> [16580.004052] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn
 > >> 1491, next_recl = 150
 > >>
 > >
 > > I understand there is nothing afterwards... This is really weird. The sequence numbers here are really crazy...
 > > I need to think that over.
 > >
 > >>
 > 
 > Ok, I finally had a change to take a closer look at this. Please run
 > with debug=0xC0000000.
 > 
 > This will be noisy, but I guess we have no choice...

It is indeed noisy, and.. I can't reproduce the problem when that's set.
Some timing related problem ?

	Dave
