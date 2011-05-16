From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 0/4] v6 Add support for network flow classifier
Date: Mon, 16 May 2011 09:32:02 -0700
Message-ID: <4DD15182.80607@intel.com>
References: <20110504183752.26394.29231.stgit@gitlad.jf.intel.com> <1305249292.14174.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"dm@chelsio.com" <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63235 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848Ab1EPQcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 12:32:03 -0400
In-Reply-To: <1305249292.14174.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/2011 6:14 PM, Ben Hutchings wrote:
> Thanks a lot for persevering with this, Alexander.
>
> I've applied this series with minor changes to the last patch.  I
> abbreviated the version history in the commit message, and I deleted a
> blank line in the manual page additions which made the indentation wrong
> for the -U option.  I also recorded the author as you, since you've
> largely rewritten it!  The commit message credits Santwona Behera.
>
> You managed to uncover a bug in the sfc driver, which is that
> set_rx_ntuple can return a positive value.  Previously ethtool accepted
> any non-negative return value as successful, so I made a separate commit
> to restore that behaviour.  Of course I'll fix the driver too.
>
> Ben.
>

Thanks for getting this all applied.  Our validation team is now testing 
the ixgbe patches with your version of ethtool and if I hear about any 
other bugs I might have introduced I will let you know.

Alex
