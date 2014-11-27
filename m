From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Thu, 27 Nov 2014 13:03:45 +0000
Message-ID: <20141127130345.GB27041@casper.infradead.org>
References: <5474B795.3080204@mojatatu.com>
 <20141125215402.GA3912@casper.infradead.org>
 <54754A10.6020601@mojatatu.com>
 <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>
 <5475BB53.3070200@mojatatu.com>
 <20141126160859.GB13786@casper.infradead.org>
 <54760939.8050805@mojatatu.com>
 <20141126175944.GW1875@nanopsycho.orion>
 <20141126215034.GA32174@casper.infradead.org>
 <547662F4.3060408@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tux
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38487 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbaK0NDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 08:03:55 -0500
Content-Disposition: inline
In-Reply-To: <547662F4.3060408@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 06:32pm, Jamal Hadi Salim wrote:
> Jiri/Scott: We'll call this offload thing hanging off a port_ops
> a "switch". It does one or more of L2, L3 and flows.
> Jamal: I am not fond of that name because not everything that offloads
> off a port is a switch (some mention of fitting even with dpdk)
> Jiri: What do you have - an L3 "switch"?
> Jamal: No, it is something that does offloading of packet processing off
> a port with flows and action. Example a netronome would be a good fit (if
> you are to ignore Simon going for OVS).

So what is your name suggestion?
