From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 RFC PATCH v3] ethtool: allow custom interval for
 physical identification
Date: Thu, 14 Apr 2011 21:19:34 -0700 (PDT)
Message-ID: <20110414.211934.193722116.davem@davemloft.net>
References: <20110413230910.16317.11372.stgit@gitlad.jf.intel.com>
	<1302830785.5282.691.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, mchan@broadcom.com, eilong@broadcom.com,
	divy@chelsio.com, pcnet32@frontier.com, jdmason@kudzu.us,
	linux-net-drivers@solarflare.com, shodgson@solarflare.com,
	shemminger@linux-foundation.org, mcarlson@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750987Ab1DOEUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 00:20:12 -0400
In-Reply-To: <1302830785.5282.691.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 15 Apr 2011 02:26:25 +0100

> On Wed, 2011-04-13 at 16:09 -0700, Bruce Allan wrote:
>> When physical identification of an adapter is done by toggling the
>> mechanism on and off through software utilizing the set_phys_id operation,
>> it is done with a fixed duration for both on and off states.  Some drivers
>> may want to set a custom duration for the on/off intervals.  This patch
>> changes the API so the return code from the driver's entry point when it
>> is called with ETHTOOL_ID_ACTIVE can specify the frequency at which to
>> cycle the on/off states, and updates the drivers that have already been
>> converted to use the new set_phys_id and use the synchronous method for
>> identifying an adapter.
>> 
>> The physical identification frequency set in the updated drivers is based
>> on how it was done prior to the introduction of set_phys_id.
>> 
>> Compile tested only.  Also fixes a compiler warning in sfc.
>> 
>> v2: drivers do not return -EINVAL for ETHOOL_ID_ACTIVE
>> v3: fold patchset into single patch and cleanup per Ben's feedback
>> 
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: Ben Hutchings <bhutchings@solarflare.com>
> [...]
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks everyone.
