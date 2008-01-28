From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2] ixgb: enable sun hardware support for broadcom phy
Date: Mon, 28 Jan 2008 15:27:24 -0800
Message-ID: <479E64DC.7050901@intel.com>
References: <20071214194829.15478.2510.stgit@localhost.localdomain> <20071214194836.15478.85555.stgit@localhost.localdomain> <47671FBD.4010402@garzik.org> <478BBB77.40404@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51504 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756859AbYA1XcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 18:32:01 -0500
In-Reply-To: <478BBB77.40404@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matheos Worku wrote:
> Jeff Garzik wrote:
>> Auke Kok wrote:
>>> From: Matheos Worku <matheos.worku@sun.com>
>>>
>>> Implement support for a SUN-specific PHY.
>>>
>>> SUN provides a modified 82597-based board with their own
>>> PHY that works with very little modification to the code. This
>>> patch implements this new PHY which is identified by the
>>> subvendor device ID. The device ID of the adapter remains
>>> the same.
>>>
>>> Signed-off-by: Matheos Worku <matheos.worku@sun.com>
>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>> ---
>>>
>>>  drivers/net/ixgb/ixgb_hw.c   |   82
>>> +++++++++++++++++++++++++++++++++++++++++-
>>>  drivers/net/ixgb/ixgb_hw.h   |    3 +-
>>>  drivers/net/ixgb/ixgb_ids.h  |    4 ++
>>>  drivers/net/ixgb/ixgb_main.c |   10 +++--
>>>  4 files changed, 91 insertions(+), 8 deletions(-)
>>
>> applied #upstream
>>
>>
> 
> Jeff,
> Bleated Happy New Year.
> 
> I was wondering when this patch will  make  it to Linus' and other
> trees. I just checked Linus's and other net trees, including
> git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git and I see only
> the other patch's commit: 3fd7131feacc01c1e23e46c416228f36ebdcc0d4, and
> not this patch.

It's in the "upstream" branch of that tree:

http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=history;f=drivers/net/ixgb;hb=upstream

this should be merged in the currently open merge window, so you'll find it
eventually in the 2.6.25 kernel release.

Cheers,

Auke


