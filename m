From: David Ahern <dsahern@gmail.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 10:38:05 -0700
Message-ID: <54EF59FD.2030107@gmail.com>
References: <20150226074214.GF2074@nanopsycho.orion> <20150226083758.GA15139@vergenet.net> <20150226091628.GA4059@nanopsycho.orion> <20150226133326.GC23050@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	jpettit@nicira.com, joestringer@nicira.com,
	john.r.fastabend@intel.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:40319 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbbBZRiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 12:38:07 -0500
Received: by iebtr6 with SMTP id tr6so18310843ieb.7
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 09:38:07 -0800 (PST)
In-Reply-To: <20150226133326.GC23050@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/15 6:33 AM, Thomas Graf wrote:
> E.g. A VRF in software would make use of net namespaces which holds
> tenant specific ACLs, routes and QoS settings. A separate action
> would fwd packets to the namespace. Easy and straight forward in
> software.

namespace == L1 separation
VRF == L3 separation

Why is there an insistence that an L1 construct is appropriate for L3 
isolation? Has anyone other than 6wind actually done a 1000+ VRFs with 
the Linux stack?

David
