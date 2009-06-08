From: Patrick McHardy <kaber@trash.net>
Subject: Re: bonds/vlan combinations and device features
Date: Mon, 08 Jun 2009 15:43:34 +0200
Message-ID: <4A2D1586.2020906@trash.net>
References: <Pine.LNX.4.64.0906081244140.7633@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35953 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbZFHNnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 09:43:37 -0400
In-Reply-To: <Pine.LNX.4.64.0906081244140.7633@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Another questions which is more related to the vlan (8021q) driver, is the lack of
> vlan passthrough (e.g setting dev->vlan_features) by most of the drivers (all expect
> for the Intel ones...) as pointed by Jay earlier on these threads. Is there a real
> issue for other HW vendors to support this or its something that got fogotten through
> the introduction of the vlan_features? I traced 289c79a4... "vlan: Use bitmask of
> feature flags instead of seperate feature bits" be to the 8021q patch and ad31c402...
> "ixbge: allow vlan devices to use TSO and TCP CSUM offload" et al to be Intel drivers
> patches, but I didn't see other drivers support.
> 
> Patrick, assuming that vlans are common and people expect NIC to support TCP offloads
> such as checksum and large-send, what is the actual gap here per your view?

Its up to the maintainers or people owning a device which doesn't yet
set those flags. I do not know which other devices support this.

