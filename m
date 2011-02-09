From: Anders Berggren <anders@halon.se>
Subject: Re: [E1000-devel] [PATCH] fixing hw timestamping in igb
Date: Wed, 9 Feb 2011 09:24:42 +0100
Message-ID: <98900162-6C81-4B10-87DD-F43B04DC3F71@halon.se>
References: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se> <1296775407.2698.10.camel@jtkirshe-MOBL1> <331E9D4A-6738-405A-8457-14858D1072DA@halon.se> <DDC57477F5D6F845A0DDCB99D3C4812D0D36DA5C59@orsmsx510.amr.corp.intel.com>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp.halon.se ([212.37.18.222]:58097 "EHLO vsp.halon.se"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752555Ab1BIIYr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 03:24:47 -0500
In-Reply-To: <DDC57477F5D6F845A0DDCB99D3C4812D0D36DA5C59@orsmsx510.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 8, 2011, at 5:27 PM, Ronciak, John wrote:

> The question of IPv6 support for TX timestamping is still under discussion.  We are trying to understand the use case for it as well as how it would be used.  We have had no customers asking for this type of support (at least not yet).  If there is kernel work going on regarding it then maybe this needs to be looked at closer. Other than being a science project, what is your use case for the TX timestamping in IPv6?

We're developing a "hardware/kernel timestamp ping" for Linux in C. It's part of a complete SLA platform (appliance based on Debian with XMLRPC APIs). It's both a science project (Chalmers University, Gothenburg) and a commercial project (Tele2).

Commercial SLA appliances from Cisco and Juniper typically have a accuracy of XXX microseconds. Our hardware ping, using Intel 82580 NICs, have an accuracy of 8 nanoseconds. That is VERY good.

The reason for supporting IPv6 is, well, because it's the future ;) 