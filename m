From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [linuxwifi] [PATCH] iwlwifi:Fix error handling in the function
 iwl_pcie_enqueue_hcmd
Date: Wed, 22 Jul 2015 17:31:51 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E7B3D53@hasmsx107.ger.corp.intel.com>
References: <1437583079-28861-1-git-send-email-xerofoify@gmail.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32E7B3D25@hasmsx107.ger.corp.intel.com>
 <55AFD306.5060303@gmail.com>
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
To: nick <xerofoify@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/22/2015 08:30 PM, nick wrote:
> 
> 
> On 2015-07-22 01:28 PM, Grumbach, Emmanuel wrote:
>>
>>
>> On 07/22/2015 07:39 PM, Nicholas Krause wrote:
>>> This fixes error handling in the function iwl_pcie_enqueue_hcmd
>>> by checking if all calls to the function wl_pcie_txq_build_tfd
>>> have failed by returning a error code and if so jump to the goto
>>> label out from the cleaning up of acquired resources before
>>
>> What tests did you run on your patch?
>>
> None did I miss something?

I can't really accept a patch if you don't even test it, right?
Your patch doesn't look problematic at first glance, but hitting
these paths isn't easy and I am not very happy to change the behavior
without direct testing.
