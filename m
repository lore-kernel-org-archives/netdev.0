From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: L2 switching in igb
Date: Thu, 10 Sep 2009 11:04:39 +0300
Message-ID: <4AA8B317.2080706@voltaire.com>
References: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com> <5f2db9d90909032135l26cfdba6n52329f6be75c16a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fischer, Anna" <anna.fischer@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:35124 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752353AbZIJIEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 04:04:40 -0400
In-Reply-To: <5f2db9d90909032135l26cfdba6n52329f6be75c16a5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote:
> The suggestion I received from Dave and Stephen was to consider an rtnl_link_ops for
> configuring the VFs, but I still have issues trying to visualize how that would work since I don't want the VFs spawning in the host/hypervisor OS as network devices.
Note that VEPA mode is a characteristic of the PF, correct? and the PF 
resides in the host kernel. Also, as I wrote you earlier, I do see many 
schemes where a VF spawned in the host kernel IS very useful, and as 
such I'd be happy to continue the discussion on the approach suggested 
by Dave and Stephen, can you provide a pointer? (thanks).

Or.

