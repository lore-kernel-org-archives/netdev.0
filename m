From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [PATCH v3] iwlwifi: dvm: use alloc_ordered_workqueue()
Date: Wed, 23 Mar 2016 08:33:41 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32EA8768F@hasmsx107.ger.corp.intel.com>
References: <1458364547-11621-1-git-send-email-eraretuya@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	linuxwifi <linuxwifi@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tj@kernel.org" <tj@kernel.org>
To: Eva Rachel Retuya <eraretuya@gmail.com>,
	"outreachy-kernel@googlegroups.com"
	<outreachy-kernel@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/19/2016 07:15 AM, Eva Rachel Retuya wrote:
> Use alloc_ordered_workqueue() to allocate the workqueue instead of
> create_singlethread_workqueue() since the latter is deprecated and is scheduled
> for removal.
> 
> There are work items doing related operations that shouldn't be swapped when
> queued in a certain order hence preserve the strict execution ordering of a
> single threaded (ST) workqueue by switching to alloc_ordered_workqueue().
> 
> WQ_MEM_RECLAIM flag is not needed since the worker is not depended
> during memory reclaim.
> 
> Signed-off-by: Eva Rachel Retuya <eraretuya@gmail.com>
> Acked-by: Tejun Heo <tj@kernel.org>
> ---


Applied - thanks.
