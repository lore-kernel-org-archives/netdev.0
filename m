From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 19:05:44 +0000
Message-ID: <20150226190544.GA1631@casper.infradead.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <CA+mtBx-sVMNFng_=DcM5mJTbzrRNsFhTvC8YxvjxcqEXwDcWWw@mail.gmail.com>
 <20150226161705.GH1973@nanopsycho.lan>
 <CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <simon.horman@netronome.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, jpettit@nicira.com,
	Joe Stringer <joestringer@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, shrijeet@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>, bcrl@kvack.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58754 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbbBZTFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:05:48 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 at 10:15am, Tom Herbert wrote:
> But, routing (aka switching) in the stack is not configured through
> TC. We have a whole forwarding and routing infrastructure (eg.
> iproute) with optimizations that  allow routes to be cached in
> sockets, etc. To me, it seems like offloading that basic functionality
> is a prerequisite before attempting to offload more advanced policy
> mechanisms of TC, netfilter, etc.

It is visible that you are coming from container focused world
with sockets on the host ;-) The L3 offload desire comes primiarly
from a VM centric host where decap+L3 offload to a VF allows to
spend zero cycles on the host kernel. I'm not sure if offload
makes sense at all for container workloads w/o VM isolation per
tentant or orch system or something similar.
