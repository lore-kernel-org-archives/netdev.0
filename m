From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 RFC PATCH v3] ethtool: allow custom interval for
 physical identification
Date: Fri, 15 Apr 2011 02:26:25 +0100
Message-ID: <1302830785.5282.691.camel@localhost>
References: <20110413230910.16317.11372.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	Don Fry <pcnet32@frontier.com>, Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6569 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754944Ab1DOB0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 21:26:31 -0400
In-Reply-To: <20110413230910.16317.11372.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-13 at 16:09 -0700, Bruce Allan wrote:
> When physical identification of an adapter is done by toggling the
> mechanism on and off through software utilizing the set_phys_id operation,
> it is done with a fixed duration for both on and off states.  Some drivers
> may want to set a custom duration for the on/off intervals.  This patch
> changes the API so the return code from the driver's entry point when it
> is called with ETHTOOL_ID_ACTIVE can specify the frequency at which to
> cycle the on/off states, and updates the drivers that have already been
> converted to use the new set_phys_id and use the synchronous method for
> identifying an adapter.
> 
> The physical identification frequency set in the updated drivers is based
> on how it was done prior to the introduction of set_phys_id.
> 
> Compile tested only.  Also fixes a compiler warning in sfc.
> 
> v2: drivers do not return -EINVAL for ETHOOL_ID_ACTIVE
> v3: fold patchset into single patch and cleanup per Ben's feedback
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
[...]
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

