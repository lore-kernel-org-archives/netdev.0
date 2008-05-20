From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 10:22:43 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051AC81F@orsmsx414.amr.corp.intel.com>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com> <4832E55E.2030009@trash.net> <4832F260.5000104@candelatech.com> <20080520162011.GT28241@solarflare.com> <4832FC1F.90208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39162 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755959AbYETRWo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 13:22:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4832FC1F.90208@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I guess it doesn't matter so much to me either way..so long 
> as it is narrowed one way or another, and preferably narrowed 
> enough to allow plenty of new flags down the road.

In addition to TSO, we also want TCP checksum offload, so we'll need at
least one more flag.  So whatever is done to shrink the GSO bits, we'll
need room for two new flags.

The patch looks good after a visual inspection.  I'll send test results
later today.

Cheers,
-PJ Waskiewicz
