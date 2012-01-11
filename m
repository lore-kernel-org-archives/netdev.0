From: Dave Jones <davej@redhat.com>
Subject: Re: iwlwifi worse than ever in current git.
Date: Wed, 11 Jan 2012 14:28:42 -0500
Message-ID: <20120111192842.GA29305@redhat.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
 <20120111014243.GA22066@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	Linux Wireless <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932560Ab2AKT2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 14:28:48 -0500
Content-Disposition: inline
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 12:38:43PM +0000, Grumbach, Emmanuel wrote:
 > > [  173.145695] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn =
 > > next_recl = 869
 > > [  173.147133] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 101
 > > [  173.147545] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate
 > > BA Queue 11 on FIFO 1
 > > [  173.148050] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra =
 > > b8:c7:5d:0c:39:88 tid = 0
 > 
 > I am missing logs here... You seem to reauthenticate but I can't see disconnection... weird
 
I'll recreate some clean logs in a few minutes..
 
 > > [  192.805102] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
 > > [  192.807392] wlan0: authenticated
 > > [  192.814840] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn
 > > 1633, next_recl = 139
 > 
 > Stop AGG before we are associated ?!
 > Is that leftovers from the previous association that was torn down ?
 
no idea.

 > > [  192.818669] wlan0: moving STA b8:c7:5d:0c:39:88 to state 2
 > > [  192.818939] wlan0: moving STA b8:c7:5d:0c:39:88 to state 1
 > > [  192.819206] wlan0: moving STA b8:c7:5d:0c:39:88 to state 0
 > > [  192.824157] wlan0: associate with b8:c7:5d:0c:39:87 (try 1)
 > 
 > Associating to another AP ? A band maybe ?
 
I only have one AP.

 > There are a few AMPDUs issues here but I guess the worst issue you are seeing is due to the passive channel thing.
 > Does it feel better with 11n disabled ?
 
5 hours of use this morning with 11n_disabled=1, and not a single problem.

I'll re-enable 11n, and get you some cleaner logs shortly.

	Dave
