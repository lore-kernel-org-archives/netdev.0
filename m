From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [PATCH] iwlwifi:Fix error handling in the function
 iwl_pcie_enqueue_hcmd
Date: Wed, 22 Jul 2015 17:28:26 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E7B3D25@hasmsx107.ger.corp.intel.com>
References: <1437583079-28861-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ilw@linux.intel.com" <ilw@linux.intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Altman, Avri" <avri.altman@intel.com>,
	"eliad@wizery.com" <eliad@wizery.com>,
	"Peer, Ilan" <ilan.peer@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5225 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934801AbbGVR2d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:28:33 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/22/2015 07:39 PM, Nicholas Krause wrote:
> This fixes error handling in the function iwl_pcie_enqueue_hcmd
> by checking if all calls to the function wl_pcie_txq_build_tfd
> have failed by returning a error code and if so jump to the goto
> label out from the cleaning up of acquired resources before

What tests did you run on your patch?
