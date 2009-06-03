From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: Question regarding protocol specific mtu for FCoE
Date: Wed, 03 Jun 2009 20:27:25 +0100
Message-ID: <1244057245.3191.17.camel@achroite>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
	 <4A26BAF7.3070301@hp.com>
	 <7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Zou, Yi" <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:48655 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbZFCT13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 15:27:29 -0400
In-Reply-To: <7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-03 at 12:16 -0700, Zou, Yi wrote:
[...]
> FCoE is on L2 layer, no path specific MTU, everything goes out as
> whatever mtu known to the nic. Since the nic is expected to be used for
> converged traffic involving multiple traffic types, e.g. LAN, FCoE, I
> was wondering if it makes sense to have the additional MTU. Essentially,
> the nic driver will be able to setup via netdev for different MTUs for
> converged traffic.

Wouldn't you use separate VLANs for FCoE and other traffic?  So maybe we
should allow for per-VLAN rather than per-protocol MTU.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

