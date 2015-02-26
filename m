From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 16:33:37 +0000
Message-ID: <20150226163337.GA21027@casper.infradead.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <20150226133326.GC23050@casper.infradead.org>
 <CAGpadYGrjfkZqe0k7D05+cy3pY=1hXZtQqtV0J-8ogU80K7BUQ@mail.gmail.com>
 <54EF3E45.3070103@intel.com>
 <CAGpadYHfNcDR2ojubkCJ8-nJTQkdLkPsAwJu0wOKU82bLDzhww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <simon.horman@netronome.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	"joestringer@nicira.com" <joestringer@nicira.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>
To: Shrijeet Mukherjee <shrijeet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58021 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbBZQdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:33:43 -0500
Content-Disposition: inline
In-Reply-To: <CAGpadYHfNcDR2ojubkCJ8-nJTQkdLkPsAwJu0wOKU82bLDzhww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 at 07:51am, Shrijeet Mukherjee wrote:
> That is the un-offload device I was referencing. If we standardize and
> implicitly make the available .. all packets that are needing to be sent to
> a construct that is not readily availble in hardware goes to this VSI and
> then software fwded. I am saying though that when this path is invoked the
> path after the VSI is not offloaded.

Agreed. I think John was pointing out how this is achievable with the
flow API while integrating into existing kernel concepts.

The point I was making is that if you have iptables ACLs that you want
offloaded you need all dependencies leading up to that iptables rule to
be programmed into hardware as well. A VRF implemented as netns is a
typical example for this but any form of network virtualization will
require this.
